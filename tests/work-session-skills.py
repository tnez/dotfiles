#!/usr/bin/env python3
"""Exercise documented commands, not model judgment, in disposable fixtures."""

import fcntl
import json
import os
from pathlib import Path
import pty
import re
import shlex
import shutil
import struct
import subprocess
import tempfile
import termios
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
TMUX = shutil.which('tmux')


class WorkSessionCommands(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix='work-skills-test-')
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name).resolve()
        self.home = self.base / 'home'
        self.home.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home),
                    'GIT_CONFIG_NOSYSTEM': '1',
                    'GIT_CONFIG_GLOBAL': os.devnull,
                    'GIT_TERMINAL_PROMPT': '0'}
        for key in ('TMUX', 'TMUX_PANE', 'GIT_DIR', 'GIT_WORK_TREE',
                    'GIT_INDEX_FILE', 'GIT_OBJECT_DIRECTORY',
                    'GIT_ALTERNATE_OBJECT_DIRECTORIES'):
            self.env.pop(key, None)
        self.source = self.base / 'source'
        self.git('init', '--initial-branch=main', str(self.source))
        self.git('-C', str(self.source), 'config', 'user.name', 'Fixture')
        self.git('-C', str(self.source), 'config', 'user.email',
                 'fixture@example.invalid')
        (self.source / 'AGENTS.md').write_text('Fixture project.\n')
        (self.source / '.gitignore').write_text('.private/\n')
        self.git('-C', str(self.source), 'add', '.')
        self.git('-C', str(self.source), 'commit', '-m', 'Fixture base')
        self.remote = self.base / 'remote.git'
        self.git('clone', '--bare', str(self.source), str(self.remote))
        self.checkout = self.base / 'work space/acme/web/password-reset'
        self.checkout.parent.mkdir(parents=True)

    def git(self, *args, check=True):
        return subprocess.run(['git', *args], env=self.env,
                              capture_output=True, text=True, timeout=10,
                              check=check)

    def cg(self, *args, check=True):
        return self.git('-C', str(self.checkout), *args, check=check)

    def acquire(self):
        self.git('clone', '--', str(self.remote), str(self.checkout))
        self.cg('fetch', 'origin', '--prune')

    def test_new_activity_and_existing_path_conflict(self):
        self.acquire()
        self.cg('check-ref-format', '--branch', 'feat/password-reset')
        self.cg('switch', '--no-track', '-c', 'feat/password-reset',
                'origin/main')
        self.assertEqual(self.cg('rev-parse', 'HEAD').stdout,
                         self.cg('rev-parse', 'origin/main').stdout)
        self.assertEqual(self.cg('status', '--porcelain').stdout, '')
        self.assertNotEqual(self.cg('rev-parse', '--verify',
                                   '@{upstream}', check=False).returncode, 0)
        result = self.git('clone', '--', str(self.remote), str(self.checkout),
                          check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.cg('branch', '--show-current').stdout.strip(),
                         'feat/password-reset')

    def test_resume_published_branch_and_preserve_dirty_state(self):
        self.git('-C', str(self.source), 'switch', '-c', 'fix/existing')
        (self.source / 'published').write_text('existing result\n')
        self.git('-C', str(self.source), 'add', '.')
        self.git('-C', str(self.source), 'commit', '-m', 'Published fixture')
        self.git('-C', str(self.source), 'push', str(self.remote),
                 'fix/existing')
        self.acquire()
        self.cg('switch', '--track', '-c', 'fix/existing',
                'origin/fix/existing')
        self.assertEqual((self.checkout / 'published').read_text(),
                         'existing result\n')
        (self.checkout / 'unfinished').write_text('keep me\n')
        self.assertIn('unfinished', self.cg('status', '--short').stdout)
        self.assertEqual((self.checkout / 'unfinished').read_text(),
                         'keep me\n')

    def test_missing_main_is_observable_without_branch_substitution(self):
        self.git('--git-dir', str(self.remote), 'branch', '-m',
                 'main', 'trunk')
        self.acquire()
        self.assertNotEqual(self.cg('show-ref', '--verify',
                                   'refs/remotes/origin/main',
                                   check=False).returncode, 0)
        self.assertEqual(self.cg('branch', '--show-current').stdout.strip(),
                         'trunk')  # Skill must ask here, not start from trunk.

    def test_cleanup_inspection_exposes_hidden_and_unpublished_work(self):
        self.acquire()
        self.cg('config', 'user.name', 'Fixture')
        self.cg('config', 'user.email', 'fixture@example.invalid')
        self.cg('switch', '--no-track', '-c', 'feat/local', 'origin/main')
        (self.checkout / 'unique').write_text('unpublished\n')
        self.cg('add', '.')
        self.cg('commit', '-m', 'Unpublished fixture')
        unique = self.cg('rev-parse', 'HEAD').stdout.strip()
        self.cg('switch', '--detach')
        (self.checkout / 'detached').write_text('detached result\n')
        self.cg('add', '.')
        self.cg('commit', '-m', 'Detached fixture')
        detached = self.cg('rev-parse', 'HEAD').stdout.strip()
        self.cg('switch', 'main')
        (self.checkout / 'stash-only').write_text('stash result\n')
        self.cg('stash', 'push', '-u', '-m', 'Fixture stash')
        (self.checkout / '.private').mkdir()
        private = self.checkout / '.private/local.db'
        private.write_text('synthetic private database\n')
        self.assertEqual(self.cg('status', '--porcelain').stdout, '')
        self.assertIn('.private/local.db', self.cg(
            'ls-files', '--others', '--ignored', '--exclude-standard',
            '-z').stdout)
        self.assertIn('Fixture stash', self.cg('stash', 'list').stdout)
        self.assertIn(detached, self.cg('reflog', '--all',
                                       '--format=%H').stdout)
        self.assertIn(unique, self.cg('for-each-ref',
                                     '--format=%(objectname)').stdout)
        self.cg('fetch', 'origin', '--prune')
        tips = self.cg('ls-remote', '--heads', '--tags', 'origin').stdout
        main = self.cg('rev-parse', 'origin/main').stdout.strip()
        self.assertIn(main, tips)
        self.assertNotEqual(self.cg('merge-base', '--is-ancestor', unique,
                                   main, check=False).returncode, 0)
        self.cg('fsck', '--full', '--no-reflogs', '--unreachable')
        # Retained, not deleted just because status is clean.
        self.assertTrue(private.exists())

    def test_preserved_disposable_fixture_can_be_removed_exactly(self):
        self.acquire()
        sibling = self.checkout.parent / 'other-activity'
        sibling.mkdir()
        (sibling / 'keep').write_text('unrelated\n')
        self.cg('fetch', 'origin', '--prune')
        tip = self.cg('rev-parse', 'origin/main').stdout.strip()
        self.assertIn(tip, self.cg('ls-remote', '--heads', 'origin').stdout)
        self.cg('merge-base', '--is-ancestor', 'HEAD', tip)
        self.assertEqual(self.cg('status', '--porcelain').stdout, '')
        self.assertEqual(self.cg('stash', 'list').stdout, '')
        self.assertEqual(self.cg('ls-files', '--others', '--ignored',
                                 '--exclude-standard', '-z').stdout, '')
        # Explicit discard/removal authority applies only to this test fixture.
        shutil.rmtree(self.checkout)
        self.assertFalse(self.checkout.exists())
        self.assertEqual((sibling / 'keep').read_text(), 'unrelated\n')
        self.assertIn(tip, self.git('--git-dir', str(self.remote),
                                   'show-ref').stdout)

    @unittest.skipUnless(TMUX, 'BLOCKED: tmux unavailable')
    def test_dev_origin_override_and_fallback_leave_scout_client_alone(self):
        self.acquire()
        binary = self.base / 'bin'
        binary.mkdir()
        calls = self.base / 'calls'
        for name in ('pi', 'nvim'):
            path = binary / name
            path.write_text('#!/bin/sh\n'
                            f'printf "%s\\n" "$@" >> '
                            f'{shlex.quote(str(calls))}\nexec sleep 300\n')
            path.chmod(0o755)
        config = self.base / 'tmux.conf'
        config.write_text('set -g default-shell /bin/bash\n'
                          'set -g default-command '
                          '"exec /bin/bash --noprofile --norc"\n')
        socket = str(self.base / 'socket')
        command = [TMUX, '-S', socket, '-f', str(config)]
        env = {**self.env, 'PATH': f'{binary}:/usr/bin:/bin',
               'TERM': 'xterm-256color', 'SHELL': '/bin/bash'}
        clients = []

        def tm(*args):
            return subprocess.check_output(command + list(args), env=env,
                                           text=True, timeout=5,
                                           stderr=subprocess.PIPE).strip()

        def cleanup():
            subprocess.run(command + ['kill-server'], env=env,
                           capture_output=True, timeout=5)
            for process, master in clients:
                process.wait(timeout=5)
                os.close(master)

        self.addCleanup(cleanup)

        def drain():
            for _, master in clients:
                try:
                    while os.read(master, 65536):
                        pass
                except (BlockingIOError, OSError):
                    pass

        def wait(predicate):
            for _ in range(100):
                drain()
                if predicate():
                    return
                time.sleep(0.05)
            self.fail('tmux fixture timed out')

        origin = tm('new-session', '-d', '-P', '-F', '#{session_id}',
                    '-s', 'origin', '-c', str(self.home))
        scout = tm('new-session', '-d', '-P', '-F', '#{session_id}',
                   '-s', 'dotfiles-agent', '-c', str(self.home))
        tm('set-option', '-t', scout, '@dotfiles-agent-popup', '1')
        pane = tm('display-message', '-p', '-t', origin, '#{pane_id}')
        for session in (origin, scout):
            master, slave = pty.openpty()
            fcntl.ioctl(slave, termios.TIOCSWINSZ,
                        struct.pack('HHHH', 80, 240, 0, 0))
            os.set_blocking(master, False)
            try:
                process = subprocess.Popen(
                    command + ['attach-session', '-t', session], env=env,
                    stdin=slave, stdout=slave, stderr=slave,
                    start_new_session=True)
            finally:
                os.close(slave)
            clients.append((process, master))
        wait(lambda: len(tm('list-clients').splitlines()) == 2)
        before = dict(row.split('|') for row in tm(
            'list-clients', '-F', '#{client_name}|#{session_id}').splitlines())
        origin_client = next(k for k, v in before.items() if v == origin)
        scout_client = next(k for k, v in before.items() if v == scout)
        # The documented override selects the outer pane, without send-keys.
        tmux_env = f'{socket},{tm("display-message", "-p", "#{pid}")},0'
        result = subprocess.run(
            [str(ROOT / 'omarchy/dot-local/bin/dev')], cwd=self.checkout,
            env={**env, 'TMUX': tmux_env, 'TMUX_PANE': pane},
            capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        sessions = tm('list-sessions', '-F',
                      '#{session_id}|#{@dev_workflow_root}|'
                      '#{@dev_workflow_ready}').splitlines()
        owned = [r.split('|')[0] for r in sessions
                 if r.endswith(f'|{self.checkout}|1')]
        self.assertEqual(len(owned), 1)
        sid = owned[0]
        tm('set-option', '-t', sid, '@activity_checkout', str(self.checkout))
        after = dict(row.split('|') for row in tm(
            'list-clients', '-F', '#{client_name}|#{session_id}').splitlines())
        self.assertEqual(after[origin_client], sid)
        self.assertEqual(after[scout_client], scout)
        wait(lambda: calls.exists() and '--append-system-prompt' in
             calls.read_text())
        self.assertNotIn('password-reset', calls.read_text())
        fallback = tm('new-session', '-d', '-P', '-F', '#{session_id}',
                      '-s', 'work-acme-web-other', '-c', str(self.checkout))
        tm('set-option', '-t', fallback, '@activity_checkout',
           str(self.checkout))
        tm('switch-client', '-c', origin_client, '-t', fallback)
        self.assertEqual(tm('show-option', '-qv', '-t', fallback,
                            '@activity_checkout'), str(self.checkout))
        clients_after_fallback = dict(row.split('|') for row in tm(
            'list-clients', '-F', '#{client_name}|#{session_id}').splitlines())
        self.assertEqual(clients_after_fallback[origin_client], fallback)
        self.assertEqual(clients_after_fallback[scout_client], scout)
        tm('kill-session', '-t', fallback)  # Approved fixture-only cleanup.
        self.assertIn(scout, tm('list-sessions', '-F', '#{session_id}'))

    @unittest.skipUnless(shutil.which('pi'), 'BLOCKED: Pi unavailable')
    def test_native_pi_discovers_both_user_skills_without_model_request(self):
        skills = self.home / '.agents/skills'
        skills.mkdir(parents=True)
        for name in ('start-work', 'clean-up-work'):
            (skills / name).symlink_to(ROOT / 'agents/skills' / name)
        # No credentials, live home resources, model prompt, or enabled tools.
        env = {'HOME': str(self.home), 'PATH': os.environ['PATH'],
               'PI_TELEMETRY': '0', 'TERM': 'xterm-256color'}
        result = subprocess.run(
            [shutil.which('pi'), '--offline', '--mode', 'rpc', '--no-session',
             '--no-extensions', '--no-mcp', '--no-context-files',
             '--no-approve', '--no-tools'], cwd=self.home, env=env,
            input=json.dumps({'id': 'skills', 'type': 'get_commands'}) + '\n',
            text=True, capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        records = [json.loads(line) for line in result.stdout.split('\n')
                   if line.strip()]
        response = next(r for r in records if r.get('id') == 'skills')
        self.assertTrue(response['success'])
        commands = response['data']['commands']
        self.assertEqual({c['name'] for c in commands},
                         {'skill:start-work', 'skill:clean-up-work'})
        for command in commands:
            self.assertEqual(command['source'], 'skill')
            self.assertEqual(command['sourceInfo']['scope'], 'user')
            self.assertEqual(command['sourceInfo']['source'], 'auto')
        self.assertEqual(result.stderr, '')

    def test_skill_resource_paths_and_names(self):
        for name in ('start-work', 'clean-up-work'):
            source = ROOT / 'agents/skills' / name / 'SKILL.md'
            text = source.read_text()
            self.assertTrue(text.startswith('---\n'))
            self.assertIn(f'\nname: {name}\n', text)
            self.assertRegex(name, r'^[a-z0-9]+(?:-[a-z0-9]+)*$')
            for link in re.findall(r'\]\(([^)]+)\)', text):
                self.assertTrue((source.parent / link).is_file(), link)


if __name__ == '__main__':
    unittest.main(verbosity=2)
