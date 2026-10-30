#!/usr/bin/env python3
"""Installer fixtures only; never activate skills in the real home."""

import argparse
import contextlib
import importlib.machinery
import importlib.util
import io
import os
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
loader = importlib.machinery.SourceFileLoader('agent_skills', str(
    ROOT / 'agent-skills'))
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)


class AgentSkills(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix='agent-skills-test-')
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name).resolve()
        self.root, self.home = (self.base / n for n in ('repo', 'home'))
        (self.root / '.git').mkdir(parents=True)
        self.home.mkdir()
        shutil.copytree(ROOT / 'agents/skills', self.root / 'agents/skills')
        lifecycle = self.root / 'dotfiles'
        lifecycle.write_text('#!/bin/sh\n'
                             'echo "$1" >> "$TEST_LOG"\n'
                             'echo "${TEST_OUTPUT:-}"\n'
                             'exit "${TEST_STATUS:-0}"\n')
        lifecycle.chmod(0o755)
        self.log = self.base / 'lifecycle.log'
        env = patch.dict(os.environ, {
            'TEST_LOG': str(self.log), 'PI_CODING_AGENT_DIR': '',
            'TEST_OUTPUT': '', 'TEST_STATUS': '0',
        })
        env.start()
        self.addCleanup(env.stop)
        host = patch.object(m.platform, 'system', return_value='Darwin')
        host.start()
        self.addCleanup(host.stop)
        self.skills = self.home / '.agents/skills'

    def call(self, command='plan', yes=False):
        self.output = io.StringIO()
        with contextlib.redirect_stdout(self.output), \
                contextlib.redirect_stderr(self.output):
            return m.run(argparse.Namespace(command=command, yes=yes),
                         self.root, self.home)

    def test_read_only_plan_and_approval(self):
        self.assertEqual(self.call(), 1)
        self.assertEqual(self.call('check'), 1)
        self.assertEqual(self.call('apply'), 3)
        self.assertEqual(list(self.home.iterdir()), [])
        self.assertFalse(self.log.exists())

    def test_exact_links_preservation_and_repeat_apply(self):
        self.skills.mkdir(parents=True)
        foreign = self.skills / 'dottie'
        foreign.symlink_to('/external/skill')
        for relative in ('.pi/agent/auth.json', '.pi/agent/settings.json',
                         '.pi/agent/sessions/private', '.agents/other'):
            path = self.home / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('keep local state\n')
        self.assertEqual(self.call('apply', yes=True), 0,
                         self.output.getvalue())
        for name in m.SKILLS:
            target = self.skills / name
            source = self.root / 'agents/skills' / name
            self.assertEqual(os.readlink(target), str(source))
            self.assertEqual((target / 'SKILL.md').read_bytes(),
                             (source / 'SKILL.md').read_bytes())
        self.assertEqual(os.readlink(foreign), '/external/skill')
        before = [(self.skills / n).lstat() for n in m.SKILLS]
        self.assertEqual(self.call('check'), 0)
        self.assertEqual(self.call('apply', yes=True), 0)
        self.assertEqual(before, [(self.skills / n).lstat()
                                 for n in m.SKILLS])
        self.assertEqual(self.log.read_text(), 'doctor\nplan\n' * 2)
        for relative in ('.pi/agent/auth.json', '.pi/agent/settings.json',
                         '.pi/agent/sessions/private', '.agents/other'):
            self.assertEqual((self.home / relative).read_text(),
                             'keep local state\n')

    def test_absent_parent_directories_created_only_on_apply(self):
        self.assertEqual(self.call(), 1)
        self.assertFalse(self.skills.exists())
        self.assertEqual(self.call('apply', yes=True), 0)
        self.assertFalse(self.skills.is_symlink())
        self.assertFalse(self.skills.parent.is_symlink())

    def test_all_conflicts_preflight_before_first_link(self):
        self.skills.mkdir(parents=True)
        target = self.skills / 'clean-up-work'
        for kind in ('file', 'directory', 'link'):
            with self.subTest(kind=kind):
                if kind == 'file':
                    target.write_text('local skill')
                elif kind == 'directory':
                    target.mkdir()
                else:
                    target.symlink_to('/missing/foreign')
                self.assertEqual(self.call('apply', yes=True), 3)
                self.assertFalse((self.skills / 'start-work').is_symlink())
                self.assertFalse(self.log.exists())
                if kind == 'directory':
                    target.rmdir()
                else:
                    target.unlink()

    def test_redirected_parents_rejected(self):
        outside = self.base / 'outside'
        outside.mkdir()
        (self.home / '.agents').symlink_to(outside)
        self.assertEqual(self.call('apply', yes=True), 3)
        self.assertEqual(list(outside.iterdir()), [])
        (self.home / '.agents').unlink()
        self.skills.parent.mkdir()
        self.skills.symlink_to(outside)
        self.assertEqual(self.call('apply', yes=True), 3)
        self.assertEqual(list(outside.iterdir()), [])

    def test_primary_platform_custom_dir_and_lifecycle_guards(self):
        for env in ({'TEST_STATUS': '1'},
                    {'TEST_OUTPUT': 'ACTION_REQUIRED: fixture'},
                    {'PI_CODING_AGENT_DIR': '/custom'}):
            with patch.dict(os.environ, env):
                self.assertEqual(self.call('apply', yes=True), 3)
            self.assertFalse(self.skills.exists())
        with patch.object(m.platform, 'system', return_value='Linux'), \
                patch.object(m.platform, 'freedesktop_os_release',
                             return_value={'ID': 'arch'}):
            self.assertEqual(self.call('apply', yes=True), 3)
        (self.root / '.git').rmdir()
        (self.root / '.git').write_text('gitdir: elsewhere')
        self.assertEqual(self.call(), 1)  # Read-only linked inspection allowed.
        self.assertEqual(self.call('apply', yes=True), 3)
        self.assertFalse(self.skills.exists())

    def test_omarchy_supported_in_fixture(self):
        with patch.object(m.platform, 'system', return_value='Linux'), \
                patch.object(m.platform, 'freedesktop_os_release',
                             return_value={'ID': 'omarchy'}):
            self.assertEqual(self.call('apply', yes=True), 0)

    def test_redirected_source_or_resource_is_refused(self):
        path = self.root / 'agents/skills/start-work/SKILL.md'
        path.unlink()
        path.symlink_to(ROOT / 'agents/skills/start-work/SKILL.md')
        self.assertEqual(self.call('apply', yes=True), 3)
        self.assertFalse(self.skills.exists())
        path.unlink()
        path.write_text('local')
        source = self.root / 'agents/skills/start-work'
        shutil.rmtree(source)
        source.symlink_to(ROOT / 'agents/skills/start-work')
        self.assertEqual(self.call('apply', yes=True), 3)

    def test_changed_source_during_review_stops_before_writes(self):
        original = m.authorize

        def change(*args):
            original(*args)
            path = self.root / 'agents/skills/start-work/SKILL.md'
            path.write_text('changed during review')

        with patch.object(m, 'authorize', side_effect=change):
            self.assertEqual(self.call('apply', yes=True), 3)
        self.assertFalse(self.skills.exists())

    def test_changed_source_after_last_link_is_reported(self):
        original = Path.symlink_to

        def change(path, *args, **kwargs):
            result = original(path, *args, **kwargs)
            if path == self.skills / 'clean-up-work':
                source = self.root / 'agents/skills/start-work/SKILL.md'
                source.write_text('changed after linking')
            return result

        with patch.object(Path, 'symlink_to', change):
            self.assertEqual(self.call('apply', yes=True), 3)
        self.assertIn('partial', self.output.getvalue())

    def test_concurrent_creation_is_not_clobbered(self):
        original = Path.symlink_to

        def race(path, *args, **kwargs):
            if path == self.skills / 'start-work':
                path.write_text('concurrent skill')
            return original(path, *args, **kwargs)

        with patch.object(Path, 'symlink_to', race):
            self.assertEqual(self.call('apply', yes=True), 3)
        self.assertEqual((self.skills / 'start-work').read_text(),
                         'concurrent skill')
        self.assertFalse((self.skills / 'clean-up-work').exists())

    def test_partial_failure_retains_first_link_and_can_resume(self):
        original = Path.symlink_to

        def fail(path, *args, **kwargs):
            if path == self.skills / 'clean-up-work':
                raise OSError('fixture link failure')
            return original(path, *args, **kwargs)

        with patch.object(Path, 'symlink_to', fail):
            self.assertEqual(self.call('apply', yes=True), 3)
        self.assertTrue((self.skills / 'start-work').is_symlink())
        self.assertIn('partial', self.output.getvalue())
        self.assertEqual(self.call(), 1)
        self.assertEqual(self.call('apply', yes=True), 0)


if __name__ == '__main__':
    unittest.main(verbosity=2)
