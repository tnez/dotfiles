#!/usr/bin/env python3
"""Disposable-home tests: no live hooks, agent config, or model requests."""

import argparse
import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader(
    'agent_links', str(ROOT / 'omarchy-agent-links'))
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)


class AgentLinks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='agent-links-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / "repo with ' quote"
        self.home = self.base / 'home'
        self.kb = self.base / "kb with ' quote"
        self.bin = self.base / 'bin'
        for path in (self.root / '.git', self.home / '.pi/agent', self.bin,
                     *(self.home / '.config/omarchy/hooks' / (e + '.d')
                       for e in m.EVENTS)):
            path.mkdir(parents=True)
        for relative in ('AGENTS.md', 'root/index.md',
                         'root/meta/agent-consumption.md'):
            path = self.kb / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('fixture KB\n')
        for relative in m.LINKS.values():
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('fixture source\n')
        self.settings = self.home / '.pi/agent/settings.json'
        self.settings.write_text(json.dumps({**m.PREFERENCES,
                                            'theme': 'keep-local',
                                            'packages': ['keep-package']}))
        self.auth = self.home / '.pi/agent/auth.json'
        self.auth.write_text('synthetic unmanaged auth fixture\n')
        self.executable(self.root / 'dotfiles', '''#!/bin/bash
printf '%s\\n' "$1" >> "$TEST_LIFECYCLE_LOG"
printf '%s' "${TEST_LIFECYCLE_OUTPUT:-}"
exit "${TEST_LIFECYCLE_EXIT:-0}"
''')
        self.executable(self.bin / 'omarchy', '''#!/usr/bin/env python3
import os
from pathlib import Path
import shutil
import sys
assert sys.argv[1:3] == ['hook', 'install']
if sys.argv[3] == os.environ.get('TEST_INSTALL_FAIL'):
    raise SystemExit(17)
target = (Path(os.environ['HOME']) / '.config/omarchy/hooks' /
          (sys.argv[3] + '.d') / Path(sys.argv[4]).name)
shutil.copyfile(sys.argv[4], target)
target.chmod(0o755)
''')
        self.env = {'HOME': str(self.home),
                    'TNEZDEV_KNOWLEDGE_BASE_ROOT': str(self.kb),
                    'TEST_LIFECYCLE_LOG': str(self.base / 'lifecycle.log'),
                    'PATH': str(self.bin) + os.pathsep + os.environ['PATH']}
        self.environment = patch.dict(os.environ, self.env)
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.host = patch.object(m, 'is_omarchy', return_value=True)
        self.host.start()
        self.addCleanup(self.host.stop)

    def executable(self, path, text):
        path.write_text(text)
        path.chmod(0o755)

    def call(self, command='check', yes=False):
        self.output = io.StringIO()
        with contextlib.redirect_stdout(self.output), \
                contextlib.redirect_stderr(self.output):
            return m.run(argparse.Namespace(command=command, yes=yes),
                         self.root, self.home)

    def populate(self):
        for relative, source in m.LINKS.items():
            (self.home / relative).symlink_to(self.root / source)

    def test_check_missing_is_read_only(self):
        before = self.settings.read_bytes()
        self.assertEqual(self.call(), 1)
        self.assertFalse((self.home / 'AGENTS.md').exists())
        self.assertEqual(self.settings.read_bytes(), before)
        self.assertFalse((self.base / 'lifecycle.log').exists())

    def test_repair_is_idempotent_and_preserves_state(self):
        before = self.settings.read_bytes(), self.auth.read_bytes()
        self.assertEqual(self.call('repair', True), 0)
        for relative, source in m.LINKS.items():
            self.assertEqual((self.home / relative).resolve(),
                             (self.root / source).resolve())
        stats = [(self.home / r).lstat() for r in m.LINKS]
        self.assertEqual(self.call('repair', True), 0)
        self.assertEqual(stats, [(self.home / r).lstat() for r in m.LINKS])
        self.assertEqual(before, (self.settings.read_bytes(),
                                  self.auth.read_bytes()))
        self.assertEqual((self.base / 'lifecycle.log').read_text(),
                         'doctor\nplan\ndoctor\nplan\n')

    def test_conflicting_last_target_prevents_all_writes(self):
        target = self.home / '.pi/agent/keybindings.json'
        target.write_text('keep local bindings')
        self.assertEqual(self.call('repair', True), 3)
        self.assertFalse((self.home / 'AGENTS.md').exists())
        self.assertEqual(target.read_text(), 'keep local bindings')

    def test_dangling_or_wrong_link_is_not_replaced(self):
        target = self.home / 'AGENTS.md'
        target.symlink_to(self.base / 'absent')
        self.assertEqual(self.call('repair', True), 3)
        self.assertEqual(os.readlink(target), str(self.base / 'absent'))
        target.unlink()
        other = self.base / 'other'
        other.write_text('local')
        target.symlink_to(other)
        self.assertEqual(self.call('repair', True), 3)
        self.assertEqual(other.read_text(), 'local')

    def test_redirected_parent_is_preserved(self):
        shutil.rmtree(self.home / '.pi/agent')
        other = self.base / 'other-agent'
        other.mkdir()
        (self.home / '.pi/agent').symlink_to(other)
        self.assertEqual(self.call('repair', True), 3)
        self.assertEqual(list(other.iterdir()), [])

    def test_absent_agent_directory_requires_review(self):
        shutil.rmtree(self.home / '.pi')
        self.assertEqual(self.call('repair', True), 3)
        self.assertFalse((self.home / '.pi').exists())

    def test_approval_and_primary_checkout_required(self):
        self.assertEqual(self.call('repair'), 3)
        (self.root / '.git').rmdir()
        (self.root / '.git').write_text('gitdir: fixture')
        self.assertEqual(self.call('repair', True), 3)
        self.assertFalse((self.home / 'AGENTS.md').exists())
        (self.root / '.git').unlink()
        (self.root / '.git').symlink_to(self.base)
        self.assertEqual(self.call('repair', True), 3)

    def test_lifecycle_failure_or_action_stops_before_write(self):
        for env in ({'TEST_LIFECYCLE_EXIT': '1'},
                    {'TEST_LIFECYCLE_OUTPUT': 'ACTION_REQUIRED: fixture'}):
            with patch.dict(os.environ, env):
                self.assertEqual(self.call('repair', True), 3)
            self.assertFalse((self.home / 'AGENTS.md').exists())

    def test_missing_or_redirected_source(self):
        source = self.root / 'agents/AGENTS.md'
        source.unlink()
        self.assertEqual(self.call('repair', True), 3)
        source.symlink_to(self.auth)
        self.assertEqual(self.call('repair', True), 3)

    def test_missing_or_relative_kb(self):
        for value in ('', 'relative', str(self.base / 'absent')):
            with patch.dict(os.environ,
                            {'TNEZDEV_KNOWLEDGE_BASE_ROOT': value}):
                self.assertEqual(self.call('repair', True), 3)
            self.assertFalse((self.home / 'AGENTS.md').exists())

    def test_preference_drift_and_malformed_settings_never_written(self):
        for text in ('{broken', '[]', '{"quietStartup":true,'
                     '"quietStartup":false}', '{}',
                     json.dumps({**m.PREFERENCES, 'quietStartup': 1})):
            self.settings.write_text(text)
            self.assertEqual(self.call('repair', True), 3)
            self.assertEqual(self.settings.read_text(), text)
            self.assertFalse((self.home / 'AGENTS.md').exists())

    def test_settings_symlink_is_preserved(self):
        self.settings.unlink()
        self.settings.symlink_to(self.auth)
        self.assertEqual(self.call('repair', True), 3)
        self.assertEqual(self.auth.read_text(),
                         'synthetic unmanaged auth fixture\n')

    def test_no_clobber_if_target_appears_after_inspection(self):
        target = self.home / 'AGENTS.md'
        symlink = Path.symlink_to

        def race(path, *args, **kwargs):
            if path == target:
                path.write_text('concurrent local file')
            return symlink(path, *args, **kwargs)

        with patch.object(Path, 'symlink_to', race):
            self.assertEqual(self.call('repair', True), 3)
        self.assertEqual(target.read_text(), 'concurrent local file')

    def test_partial_failure_reported_without_removing_links(self):
        symlink = Path.symlink_to

        def failure(path, *args, **kwargs):
            if path.name == 'keybindings.json':
                raise OSError('fixture failure')
            return symlink(path, *args, **kwargs)

        with patch.object(Path, 'symlink_to', failure):
            self.assertEqual(self.call('repair', True), 3)
        self.assertTrue((self.home / 'AGENTS.md').is_symlink())
        self.assertIn('partial work', self.output.getvalue())

    def test_hook_installation_is_scoped_and_repeatable(self):
        self.populate()
        keep = self.home / '.config/omarchy/hooks/post-update.d/keep'
        keep.write_text('unrelated')
        self.assertEqual(self.call('install-hooks', True), 0)
        targets = [self.home / '.config/omarchy/hooks' / (e + '.d') /
                   m.HOOK_NAME for e in m.EVENTS]
        before = [p.stat() for p in targets]
        self.assertEqual(self.call('install-hooks', True), 0)
        self.assertEqual(before, [p.stat() for p in targets])
        self.assertEqual(keep.read_text(), 'unrelated')
        for path in targets:
            self.assertEqual(path.read_text(), m.hook_text(self.root,
                                                         str(self.kb)))
            subprocess.run(['bash', '-n', str(path)], check=True)
            subprocess.run(['shellcheck', str(path)], check=True)

    def test_hook_conflict_prevents_either_installation(self):
        self.populate()
        directory = self.home / '.config/omarchy/hooks'
        target = directory / 'post-boot.d' / m.HOOK_NAME
        target.write_text('keep local hook')
        self.assertEqual(self.call('install-hooks', True), 3)
        self.assertFalse((directory / 'post-update.d' / m.HOOK_NAME).exists())
        self.assertEqual(target.read_text(), 'keep local hook')

    def test_partial_hook_installation_failure_is_reported(self):
        self.populate()
        with patch.dict(os.environ, {'TEST_INSTALL_FAIL': 'post-boot'}):
            self.assertEqual(self.call('install-hooks', True), 3)
        directory = self.home / '.config/omarchy/hooks'
        self.assertTrue((directory / 'post-update.d' / m.HOOK_NAME).is_file())
        self.assertFalse((directory / 'post-boot.d' / m.HOOK_NAME).exists())
        self.assertIn('partial work', self.output.getvalue())

    def test_hook_uses_recorded_fallback_and_preserves_override(self):
        script = self.base / 'hook'
        script.write_text(m.hook_text(self.root, str(self.kb)))
        self.executable(self.bin / 'uname', '#!/bin/sh\necho Linux\n')
        self.executable(self.bin / 'python3', '''#!/bin/bash
printf '%s' "$TNEZDEV_KNOWLEDGE_BASE_ROOT" > "$TEST_HOOK_LOG"
exit "${TEST_HOOK_EXIT:-0}"
''')
        for value in ('', '/explicit override'):
            env = {**os.environ, 'TNEZDEV_KNOWLEDGE_BASE_ROOT': value,
                   'TEST_HOOK_LOG': str(self.base / 'hook.log')}
            subprocess.run(['bash', str(script)], env=env, check=True,
                           capture_output=True)
            self.assertEqual((self.base / 'hook.log').read_text(),
                             value or str(self.kb))
        self.executable(self.bin / 'notify-send', '#!/bin/sh\nexit 0\n')
        env['TEST_HOOK_EXIT'] = '3'
        result = subprocess.run(['bash', str(script)], env=env,
                                capture_output=True)
        self.assertEqual(result.returncode, 3)

    def test_darwin_and_other_linux_are_noops(self):
        self.host.stop()
        for system, release in (('Darwin', None), ('Linux', {'ID': 'arch'})):
            with patch.object(m.platform, 'system', return_value=system), \
                    patch.object(m.platform, 'freedesktop_os_release',
                                 return_value=release):
                for command in ('check', 'repair', 'install-hooks'):
                    self.assertEqual(self.call(command, True), 0)
            self.assertFalse((self.base / 'lifecycle.log').exists())
        # The copied shell hook also skips Darwin before invoking Python.
        self.executable(self.bin / 'uname', '#!/bin/sh\necho Darwin\n')
        script = self.base / 'hook'
        script.write_text(m.hook_text(self.root, str(self.kb)))
        self.executable(self.bin / 'python3', '#!/bin/sh\nexit 99\n')
        subprocess.run(['bash', str(script)], check=True)


if __name__ == '__main__':
    unittest.main(verbosity=2)
