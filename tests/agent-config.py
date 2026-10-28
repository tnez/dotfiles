#!/usr/bin/env python3
"""Synthetic disposable-home coverage; no live config or model requests."""

import argparse
import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import stat
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('agent_config', str(
    ROOT / 'agent-config'))
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)


class AgentConfig(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix='agent-config-test-')
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name)
        self.root, self.home, self.kb = (self.base / name for name in (
            'repo', 'home', 'kb'))
        for path in (self.root / '.git', self.home / '.pi/agent',
                     self.home / '.codex'):
            path.mkdir(parents=True)
        for name in ('agents/AGENTS.md', 'pi/preferences.json',
                     'pi/dot-pi/agent/keybindings.json'):
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / name, target)
        for name in ('AGENTS.md', 'root/index.md',
                     'root/meta/agent-consumption.md'):
            path = self.kb / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('synthetic KB\n')
        lifecycle = self.root / 'dotfiles'
        lifecycle.write_text('#!/bin/sh\n'
                             'echo "$1" >> "$TEST_LOG"\n'
                             'echo "${TEST_OUTPUT:-}"\n'
                             'exit "${TEST_STATUS:-0}"\n')
        lifecycle.chmod(0o755)
        self.env = patch.dict(os.environ, {
            'TNEZDEV_KNOWLEDGE_BASE_ROOT': str(self.kb),
            'PI_CODING_AGENT_DIR': '',
            'TEST_LOG': str(self.base / 'lifecycle.log'),
        })
        self.env.start()
        self.addCleanup(self.env.stop)
        self.host = patch.object(m.platform, 'system', return_value='Darwin')
        self.host.start()
        self.addCleanup(self.host.stop)
        self.settings = self.home / '.pi/agent/settings.json'
        self.settings.write_text(json.dumps({
            'theme': 'keep-local', 'packages': ['keep-package'],
            'defaultModel': 'old',
            'modelThinkingLevels': {'other/model': 'low'},
            'defaultTools': ['read', 'bash', '-codemode'],
        }))
        self.auth = self.home / '.pi/agent/auth.json'
        self.auth.write_text('synthetic private state\n')
        self.auth.chmod(0o600)

    def call(self, command='plan', yes=False, migrate=False, restore=False):
        self.output = io.StringIO()
        with contextlib.redirect_stdout(self.output), \
                contextlib.redirect_stderr(self.output):
            return m.run(argparse.Namespace(
                command=command, yes=yes, migrate_links=migrate,
                restore_declared=restore), self.root, self.home)

    def apply(self):
        return self.call('apply', yes=True, migrate=True, restore=True)

    def test_plan_read_only_and_approval_required(self):
        before = self.settings.read_bytes()
        self.assertEqual(self.call(), 1)
        self.assertEqual(self.call('apply'), 3)
        self.assertEqual(self.call('apply', yes=True), 3)
        self.assertFalse((self.home / 'AGENTS.md').exists())
        self.assertEqual(self.settings.read_bytes(), before)
        self.assertFalse((self.base / 'lifecycle.log').exists())

    def test_apply_regular_files_merge_and_idempotence(self):
        self.settings.chmod(0o640)
        self.assertEqual(self.apply(), 0, self.output.getvalue())
        settings = json.loads(self.settings.read_text())
        self.assertEqual(settings['theme'], 'keep-local')
        self.assertEqual(settings['packages'], ['keep-package'])
        self.assertEqual(settings['defaultModel'], 'gpt-6.1-sol')
        self.assertEqual(settings['defaultThinkingLevel'], 'high')
        self.assertEqual(settings['enabledModels'], [
            'openai/gpt-6-astra:high', 'openai/gpt-6-luna:high',
            'openai/gpt-6.1-sol:high'])
        self.assertEqual(settings['modelThinkingLevels']['other/model'],
                         'low')
        self.assertEqual(settings['defaultTools'],
                         ['read', 'bash', '+codemode'])
        self.assertEqual(stat.S_IMODE(self.settings.stat().st_mode), 0o640)
        self.assertEqual(self.auth.read_text(), 'synthetic private state\n')
        for relative in m.FILES:
            path = self.home / relative
            self.assertFalse(path.is_symlink())
            self.assertEqual(path.read_bytes(), (
                self.root / 'agents/AGENTS.md').read_bytes())
        tracked = [self.home / r for r in m.FILES] + [self.settings]
        before = [p.stat() for p in tracked]
        self.assertEqual(self.apply(), 0)
        self.assertEqual(before, [p.stat() for p in tracked])
        self.assertEqual(self.call('check'), 0)
        state = self.home / '.local/state/dotfiles/agent-config'
        backup = next(state.iterdir())
        self.assertEqual(stat.S_IMODE(backup.stat().st_mode), 0o700)
        self.assertTrue(list(backup.glob('*.before')))

    def test_known_links_migrate_without_writing_repository(self):
        for relative, source in m.FILES.items():
            (self.home / relative).symlink_to(self.root / source)
        bindings = self.home / '.pi/agent/keybindings.json'
        source = self.root / 'pi/dot-pi/agent/keybindings.json'
        bindings.symlink_to(source)
        sources = [(p, p.read_bytes()) for p in (
            self.root / 'agents/AGENTS.md', source)]
        self.assertEqual(self.call('apply', yes=True, restore=True), 3)
        self.assertEqual(self.apply(), 0, self.output.getvalue())
        self.assertFalse(bindings.is_symlink())
        for path, before in sources:
            self.assertEqual(path.read_bytes(), before)

    def test_malformed_settings_prevents_all_writes(self):
        for text in ('{bad', '[]', '{"x":1,"x":2}',
                     '{"defaultTools":false}',
                     '{"modelThinkingLevels":[]}'):
            self.settings.write_text(text)
            self.assertEqual(self.apply(), 3)
            self.assertEqual(self.settings.read_text(), text)
            self.assertFalse((self.home / 'AGENTS.md').exists())

    def test_unknown_links_and_redirected_parents_preserved(self):
        target = self.home / 'AGENTS.md'
        target.symlink_to(self.auth)
        self.assertEqual(self.apply(), 3)
        self.assertTrue(target.is_symlink())
        target.unlink()
        shutil.rmtree(self.home / '.codex')
        (self.home / '.codex').symlink_to(self.home / '.pi/agent')
        self.assertEqual(self.apply(), 3)
        self.assertFalse(target.exists())

    def test_settings_link_never_adopted(self):
        self.settings.unlink()
        self.settings.symlink_to(self.auth)
        self.assertEqual(self.apply(), 3)
        self.assertTrue(self.settings.is_symlink())
        self.assertEqual(self.auth.read_text(), 'synthetic private state\n')

    def test_missing_directories_require_review(self):
        shutil.rmtree(self.home / '.codex')
        self.assertEqual(self.apply(), 3)
        self.assertFalse((self.home / '.codex').exists())

    def test_absent_settings_can_be_materialized(self):
        self.settings.unlink()
        self.assertEqual(self.apply(), 0)
        self.assertEqual(json.loads(self.settings.read_text())['defaultTools'],
                         ['+codemode'])

    def test_keybindings_merge_preserves_unrelated_actions(self):
        target = self.home / '.pi/agent/keybindings.json'
        target.write_text('{"custom.action":["ctrl+q"]}')
        self.assertEqual(self.apply(), 0)
        self.assertEqual(json.loads(target.read_text())['custom.action'],
                         ['ctrl+q'])

    def test_primary_lifecycle_kb_and_platform_guards(self):
        for env in ({'TEST_STATUS': '1'},
                    {'TEST_OUTPUT': 'ACTION_REQUIRED: fixture'},
                    {'TNEZDEV_KNOWLEDGE_BASE_ROOT': ''},
                    {'PI_CODING_AGENT_DIR': '/custom'}):
            with patch.dict(os.environ, env):
                self.assertEqual(self.apply(), 3)
            self.assertFalse((self.home / 'AGENTS.md').exists())
        (self.root / '.git').rmdir()
        (self.root / '.git').write_text('gitdir: fixture')
        self.assertEqual(self.apply(), 3)
        with patch.object(m.platform, 'system', return_value='Linux'), \
                patch.object(m.platform, 'freedesktop_os_release',
                             return_value={'ID': 'arch'}):
            self.assertEqual(self.apply(), 3)

    def test_concurrent_creation_is_not_clobbered(self):
        original = os.link
        target = self.home / 'AGENTS.md'

        def race(source, destination):
            if destination == target:
                target.write_text('concurrent writer')
            return original(source, destination)

        with patch.object(m.os, 'link', side_effect=race):
            self.assertEqual(self.apply(), 3)
        self.assertEqual(target.read_text(), 'concurrent writer')
        self.assertIn('partial work', self.output.getvalue())
        self.assertFalse(list(self.home.glob('.agent-config-*')))

    def test_redirected_sources_and_backup_directory_are_refused(self):
        source = self.root / 'pi/preferences.json'
        before = source.read_bytes()
        source.unlink()
        source.symlink_to(ROOT / 'pi/preferences.json')
        self.assertEqual(self.apply(), 3)
        self.assertFalse((self.home / 'AGENTS.md').exists())
        source.unlink()
        source.write_bytes(before)
        (self.home / '.local').symlink_to(self.base)
        self.assertEqual(self.apply(), 3)
        self.assertFalse((self.home / 'AGENTS.md').exists())

    def test_dangling_links_are_not_read_or_replaced(self):
        target = self.home / 'AGENTS.md'
        target.symlink_to(self.base / 'absent')
        self.assertEqual(self.apply(), 3)
        self.assertTrue(target.is_symlink())
        self.assertIn('preserve unknown link', self.output.getvalue())

    def test_changed_preimage_stops_before_replacement(self):
        replace = m.os.replace
        snapshot = m.snapshot
        seen = 0

        def changed(path):
            nonlocal seen
            if path == self.settings:
                seen += 1
                # Two reads per inspect, then pre-write and pre-replace reads.
                if seen == 6:
                    path.write_text('{"concurrent":"keep"}')
            return snapshot(path)

        with patch.object(m, 'snapshot', side_effect=changed), \
                patch.object(m.os, 'replace', wraps=replace) as replaced:
            self.assertEqual(self.apply(), 3)
            replaced.assert_not_called()
        self.assertEqual(self.settings.read_text(), '{"concurrent":"keep"}')
        self.assertIn('partial work', self.output.getvalue())

    def test_failure_retains_backup_and_reports_partial_work(self):
        with patch.object(m.os, 'replace', side_effect=OSError('fixture')):
            self.assertEqual(self.apply(), 3)
        self.assertIn('partial work', self.output.getvalue())
        self.assertTrue((self.home / 'AGENTS.md').is_file())
        self.assertFalse(list(self.settings.parent.glob('.agent-config-*')))


if __name__ == '__main__':
    unittest.main(verbosity=2)
