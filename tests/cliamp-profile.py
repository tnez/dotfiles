#!/usr/bin/env python3
"""Exercise the profile runbook only in disposable homes with mocked gates."""

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
loader = importlib.machinery.SourceFileLoader(
    'mux_profile', str(ROOT / 'cliamp/mux-profile'))
spec = importlib.util.spec_from_loader(loader.name, loader)
profile = importlib.util.module_from_spec(spec)
loader.exec_module(profile)


class ProfileTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles-cliamp-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.repo.mkdir()
        (self.repo / '.git').mkdir()
        self.home = self.root / 'home'
        self.home.mkdir()
        self.config = self.home / '.config'
        self.general = self.config / 'cliamp'
        self.general.mkdir(parents=True)
        (self.general / 'config.toml').write_text('theme = "local"\n')
        (self.general / 'resume.json').write_text('private state\n')
        self.target = self.general / 'profiles/mux'
        self.addCleanup(patch.stopall)
        patch.object(profile, 'ROOT', self.repo).start()
        patch.dict(os.environ, {
            'HOME': str(self.home), 'XDG_CONFIG_HOME': str(self.config),
        }, clear=True).start()
        patch.object(profile.platform, 'system', return_value='Linux').start()
        patch.object(profile.platform, 'freedesktop_os_release',
                     return_value={'ID': 'omarchy'}).start()
        self.health = patch('subprocess.run').start()
        self.health.return_value.returncode = 0

    def runbook(self, *args):
        output = io.StringIO()
        with patch('sys.argv', ['mux-profile', *args]), \
                contextlib.redirect_stdout(output), \
                contextlib.redirect_stderr(output):
            status = profile.main()
        return status, output.getvalue()

    def snapshot(self):
        return {str(p.relative_to(self.home)): (
            p.read_bytes(), p.stat().st_mtime_ns, p.stat().st_mode)
            for p in self.home.rglob('*') if p.is_file()}

    def apply(self):
        status, output = self.runbook('apply', '--yes')
        self.assertEqual(status, 0, output)

    def test_read_only_plan_and_missing_check(self):
        before = self.snapshot()
        self.assertEqual(self.runbook('plan')[0], 0)
        self.assertEqual(self.runbook('check')[0], 1)
        self.assertFalse(self.target.exists())
        self.assertEqual(self.snapshot(), before)
        self.health.assert_not_called()

    def test_setup_repeat_and_preservation(self):
        before = self.snapshot()
        self.apply()
        for name, data in before.items():
            self.assertEqual(self.snapshot()[name], data)
        local = self.target / 'config.toml'
        local.write_text('theme = "My local theme"\n' + local.read_text())
        (self.target / 'history.toml').write_text('local history\n')
        (self.target / 'resume.json').write_text('local resume\n')
        ready = self.snapshot()
        self.apply()
        self.assertEqual(self.runbook('check')[0], 0)
        self.assertEqual(self.snapshot(), ready)
        self.assertEqual(self.health.call_count, 4)
        self.assertEqual(self.health.call_args_list[0].args[0][-1], 'doctor')
        self.assertEqual(self.health.call_args_list[1].args[0][-1], 'plan')
        self.assertEqual(local.stat().st_mode & 0o777, 0o600)

    def test_approval_primary_and_platform_gates(self):
        self.assertEqual(self.runbook('apply')[0], 3)
        self.assertFalse(self.target.exists())
        (self.repo / '.git').rmdir()
        (self.repo / '.git').write_text('gitdir: elsewhere\n')
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertFalse(self.target.exists())
        (self.repo / '.git').unlink()
        (self.repo / '.git').mkdir()
        with patch.object(profile.platform, 'system', return_value='Darwin'):
            self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertFalse(self.target.exists())
        self.health.assert_not_called()

    def test_root_health_failure_blocks_mutation(self):
        self.health.return_value.returncode = 3
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertFalse(self.target.exists())
        self.assertEqual(self.health.call_count, 1)

    def test_plan_health_failure_also_blocks_mutation(self):
        self.health.side_effect = [
            type('Result', (), {'returncode': 0})(),
            type('Result', (), {'returncode': 3})(),
        ]
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertFalse(self.target.exists())
        self.assertEqual(self.health.call_count, 2)

    def test_partial_creation_is_preserved_and_reported(self):
        original = os.open

        def fail_playlist(path, *args):
            if str(path).endswith('work.toml'):
                raise OSError('simulated write failure')
            return original(path, *args)

        with patch.object(profile.os, 'open', side_effect=fail_playlist):
            self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertTrue((self.target / 'config.toml').is_file())
        before = self.snapshot()
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertEqual(self.snapshot(), before)

    def test_unmanaged_profile_is_not_adopted(self):
        self.target.mkdir(parents=True)
        (self.target / 'keep').write_text('mine\n')
        before = self.snapshot()
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertEqual(self.snapshot(), before)
        self.health.assert_not_called()

    def test_preference_and_playlist_drift_stop_even_with_yes(self):
        self.apply()
        cfg = self.target / 'config.toml'
        cfg.write_text(cfg.read_text().replace('auto_play = false',
                                               'auto_play = true'))
        before = self.snapshot()
        status, output = self.runbook('apply', '--yes')
        self.assertEqual(status, 3)
        self.assertIn('preference drift: auto_play', output)
        self.assertEqual(self.snapshot(), before)
        shutil.copyfile(ROOT / 'cliamp/mux/config.toml', cfg)
        (self.target / 'playlists/work.toml').write_text('local playlist\n')
        before = self.snapshot()
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertEqual(self.snapshot(), before)

    def test_added_providers_and_incomplete_state_are_not_repaired(self):
        self.apply()
        cfg = self.target / 'config.toml'
        cfg.write_text(cfg.read_text() + '\n[spotify]\nenabled = true\n')
        self.assertEqual(self.runbook('check')[0], 3)
        shutil.copyfile(ROOT / 'cliamp/mux/config.toml', cfg)
        (self.target / 'playlists/work.toml').unlink()
        before = self.snapshot()
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertEqual(self.snapshot(), before)

    def test_symlink_directory_and_file_refused(self):
        elsewhere = self.root / 'elsewhere'
        elsewhere.mkdir()
        (self.general / 'profiles').symlink_to(
            elsewhere, target_is_directory=True)
        self.assertEqual(self.runbook('apply', '--yes')[0], 3)
        self.assertFalse(list(elsewhere.iterdir()))
        (self.general / 'profiles').unlink()
        self.apply()
        cfg = self.target / 'config.toml'
        cfg.unlink()
        cfg.symlink_to(ROOT / 'cliamp/mux/config.toml')
        self.assertEqual(self.runbook('check')[0], 3)

    def test_bad_toml_and_marker_report_without_exposing_values(self):
        self.apply()
        cfg = self.target / 'config.toml'
        cfg.write_text('secret = [\n')
        status, output = self.runbook('check')
        self.assertEqual(status, 3)
        self.assertNotIn('secret', output)
        shutil.copyfile(ROOT / 'cliamp/mux/config.toml', cfg)
        (self.target / profile.MARKER).write_text('{}')
        self.assertEqual(self.runbook('check')[0], 3)


if __name__ == '__main__':
    unittest.main(verbosity=2)
