#!/usr/bin/env python3
"""Test desktop preference ownership in disposable homes; no live reloads."""

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
    'desktop_preferences', str(ROOT / 'omarchy-preferences'))
spec = importlib.util.spec_from_loader(loader.name, loader)
prefs = importlib.util.module_from_spec(spec)
loader.exec_module(prefs)


class PreferenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles-desktop-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.repo.mkdir()
        (self.repo / '.git').mkdir()
        shutil.copytree(ROOT / 'omarchy/dot-config',
                        self.repo / 'omarchy/dot-config')
        self.home = self.root / 'home'
        self.config = self.home / '.config'
        (self.config / 'hypr').mkdir(parents=True)
        (self.config / 'omarchy').mkdir()
        self.shell = self.config / 'omarchy/shell.json'
        self.raw = (
            '{\n  "version":1, "idle":{"lock":900},\n'
            '  "bar": { "position" : "left", "transparent":true },\n'
            '  "plugins":[{"id":"mine", "position":"right"}],\n'
            '  "note":"unicode: café; position: left"\n}\n'
        ).encode('utf-8')
        self.shell.write_bytes(self.raw)
        self.shell.chmod(0o640)
        self.hypr = self.config / 'hypr/hyprland.lua'
        self.hypr.write_text('require("hypr.dottie")\n' + prefs.LOADER)
        for name in (prefs.INPUT, prefs.BAR):
            (self.config / name).symlink_to(
                self.repo / 'omarchy/dot-config' / name)
        (self.config / 'hypr/input.lua').write_text('-- local input\n')
        (self.config / 'omarchy/runtime.json').write_text('local state\n')
        self.addCleanup(patch.stopall)
        patch.object(prefs, 'ROOT', self.repo).start()
        patch.dict(os.environ, {'HOME': str(self.home)}, clear=True).start()
        patch.object(prefs.platform, 'system', return_value='Linux').start()
        patch.object(prefs.platform, 'freedesktop_os_release',
                     return_value={'ID': 'omarchy'}).start()
        self.health = patch.object(prefs.subprocess, 'run').start()
        self.health.return_value = subprocess.CompletedProcess(
            [], 0, stdout='', stderr='')

    def runbook(self, *args):
        output = io.StringIO()
        with patch('sys.argv', ['omarchy-preferences', *args]), \
                contextlib.redirect_stdout(output), \
                contextlib.redirect_stderr(output):
            status = prefs.main()
        return status, output.getvalue()

    def snapshot(self):
        return {str(p.relative_to(self.home)): (
            p.read_bytes(), p.stat().st_mtime_ns, p.stat().st_mode)
            for p in self.home.rglob('*') if p.is_file()}

    def drift(self):
        self.shell.write_bytes(self.raw.replace(b'"left"', b'"top"', 1))

    def apply(self):
        return self.runbook('apply', '--yes', '--restore-bar-position')

    def test_check_plan_are_read_only_and_noop_apply_has_no_backup(self):
        before = self.snapshot()
        for command in ('check', 'plan'):
            self.assertEqual(self.runbook(command)[0], 0)
        self.health.assert_not_called()
        self.assertEqual(self.runbook('apply', '--yes')[0], 0)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.health.call_count, 2)
        self.assertEqual(self.health.call_args_list[0].args[0][-1], 'doctor')
        self.assertEqual(self.health.call_args_list[1].args[0][-1], 'plan')

    def test_missing_links_or_last_include_are_pending_not_created(self):
        for name in (prefs.INPUT, prefs.BAR):
            (self.config / name).unlink()
        self.hypr.write_text('require("hypr.dottie")\n')
        before = self.snapshot()
        status, output = self.runbook('plan')
        self.assertEqual(status, 1)
        self.assertIn('PENDING', output)
        self.assertNotIn('ACTION_REQUIRED', output)
        self.assertEqual(self.snapshot(), before)

    def test_bar_drift_requires_separate_policy_choice(self):
        self.drift()
        before = self.snapshot()
        for args in [('check',), ('plan',), ('apply', '--yes'),
                     ('apply', '--restore-bar-position')]:
            status, output = self.runbook(*args)
            self.assertEqual(status, 3)
            self.assertIn('ACTION_REQUIRED', output)
        self.assertEqual(self.snapshot(), before)
        self.health.assert_not_called()

    def test_restore_preserves_other_bytes_permissions_and_state(self):
        self.drift()
        before = self.snapshot()
        original = self.shell.read_bytes()
        status, output = self.apply()
        self.assertEqual(status, 0, output)
        self.assertEqual(self.shell.read_bytes(), self.raw)
        self.assertEqual(self.shell.stat().st_mode & 0o777, 0o640)
        backups = list(self.shell.parent.glob('.shell.json.dotfiles-backup-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_bytes(), original)
        self.assertEqual(backups[0].stat().st_mode & 0o777, 0o600)
        after = self.snapshot()
        for path, value in before.items():
            if path != '.config/omarchy/shell.json':
                self.assertEqual(after[path], value)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(self.snapshot(), after)

    def test_targeted_json_token_handles_order_escaping_and_nested_names(self):
        raw = (b'{"bar":{"other":{"position":"left"},'
               b'"p\\u006fsition":"right"},"version":1}')
        expected = raw.replace(b'"right"', b'"left"')
        self.shell.write_bytes(raw)
        self.assertEqual(self.apply()[0], 0)
        self.assertEqual(self.shell.read_bytes(), expected)

    def test_duplicate_invalid_or_unrecognized_schema_refused(self):
        invalid = [
            b'{"private_value":',
            b'{"version":1,"bar":{"position":"top","position":"left"}}',
            b'{"version":1,"bar":{"position":"left"},"x":NaN}',
            b'{"version":2,"bar":{"position":"left"}}',
            b'{"version":true,"bar":{"position":"left"}}',
            b'{"version":1,"bar":{}}',
            b'{"version":1,"bar":{"position":null}}',
            b'[]',
        ]
        for raw in invalid:
            self.shell.write_bytes(raw)
            before = self.snapshot()
            status, output = self.apply()
            self.assertEqual(status, 3, raw)
            self.assertNotIn('private_value', output)
            self.assertEqual(self.snapshot(), before)
        self.health.assert_not_called()

    def test_missing_shell_file_is_not_seeded(self):
        self.shell.unlink()
        self.assertEqual(self.apply()[0], 3)
        self.assertFalse(self.shell.exists())
        self.health.assert_not_called()

    def test_checkout_platform_and_approval_gates(self):
        self.drift()
        before = self.snapshot()
        (self.repo / '.git').rmdir()
        (self.repo / '.git').write_text('gitdir: elsewhere\n')
        self.assertEqual(self.apply()[0], 3)
        (self.repo / '.git').unlink()
        (self.repo / '.git').mkdir()
        with patch.object(prefs.platform, 'system', return_value='Darwin'):
            self.assertEqual(self.apply()[0], 3)
        with patch.object(prefs.platform, 'freedesktop_os_release',
                          return_value={'ID': 'arch'}):
            self.assertEqual(self.apply()[0], 3)
        self.assertEqual(self.snapshot(), before)
        self.health.assert_not_called()

    def test_health_failures_and_action_required_even_with_zero_exit(self):
        self.drift()
        before = self.snapshot()
        ok = subprocess.CompletedProcess([], 0, stdout='', stderr='')
        bad = subprocess.CompletedProcess([], 1, stdout='', stderr='')
        action = subprocess.CompletedProcess(
            [], 0, stdout='ACTION_REQUIRED: policy decision\n', stderr='')
        for results in ([bad], [ok, bad], [action], [ok, action]):
            self.health.side_effect = results
            self.assertEqual(self.apply()[0], 3)
            self.assertEqual(self.snapshot(), before)

    def test_symlinks_hardlinks_and_unsafe_parents_refused(self):
        original = self.root / 'original.json'
        self.shell.rename(original)
        self.shell.symlink_to(original)
        self.assertEqual(self.apply()[0], 3)
        self.shell.unlink()
        os.link(original, self.shell)
        self.assertEqual(self.apply()[0], 3)
        self.shell.unlink()
        original.rename(self.shell)
        moved = self.root / 'moved'
        self.shell.parent.rename(moved)
        self.shell.parent.symlink_to(moved, target_is_directory=True)
        self.assertEqual(self.apply()[0], 3)
        self.health.assert_not_called()

    def test_unowned_preference_link_or_file_refused(self):
        target = self.config / prefs.INPUT
        target.unlink()
        target.write_text('-- mine\n')
        self.assertEqual(self.runbook('check')[0], 3)
        target.unlink()
        target.symlink_to(self.config / 'hypr/input.lua')
        self.assertEqual(self.runbook('check')[0], 3)

    def test_xdg_path_and_relative_path_refusal(self):
        with patch.dict(os.environ, {'XDG_CONFIG_HOME': str(self.config)}):
            self.assertEqual(self.runbook('check')[0], 0)
        with patch.dict(os.environ, {'XDG_CONFIG_HOME': 'relative'}):
            self.assertEqual(self.apply()[0], 3)

    def test_concurrent_change_after_health_is_preserved(self):
        self.drift()

        def health(*args, **kwargs):
            self.shell.write_bytes(self.raw.replace(b'900', b'1200'))
            return subprocess.CompletedProcess([], 0, stdout='', stderr='')

        self.health.side_effect = health
        status, output = self.apply()
        self.assertEqual(status, 3)
        self.assertIn('changed during review', output)
        self.assertIn(b'1200', self.shell.read_bytes())
        self.assertFalse(list(self.shell.parent.glob('.shell.json.dotfiles-*')))

    def assert_no_write_temp(self):
        self.assertFalse(list(self.shell.parent.glob(
            '.shell.json.dotfiles-write-*')))

    def test_change_while_preparing_write_is_preserved(self):
        self.drift()
        original = prefs.tempfile.mkstemp

        def temp(*args, **kwargs):
            result = original(*args, **kwargs)
            if 'write' in kwargs['prefix']:
                self.shell.write_bytes(self.raw.replace(b'900', b'1800'))
            return result

        with patch.object(prefs.tempfile, 'mkstemp', side_effect=temp):
            self.assertEqual(self.apply()[0], 3)
        self.assertIn(b'1800', self.shell.read_bytes())
        self.assertEqual(len(list(self.shell.parent.glob(
            '.shell.json.dotfiles-backup-*'))), 1)
        self.assert_no_write_temp()

    def test_write_failure_preserves_original_and_retains_private_backup(self):
        self.drift()
        before = self.shell.read_bytes()
        with patch.object(prefs.os, 'replace', side_effect=OSError('test')):
            self.assertEqual(self.apply()[0], 3)
        self.assertEqual(self.shell.read_bytes(), before)
        self.assertEqual(len(list(self.shell.parent.glob(
            '.shell.json.dotfiles-backup-*'))), 1)
        self.assert_no_write_temp()

    def test_requested_live_failure_blocks_bar_mutation(self):
        self.drift()
        before = self.snapshot()
        self.health.return_value = subprocess.CompletedProcess(
            [], 0, stdout=json.dumps({'bool': False}), stderr='')
        status, output = self.runbook(
            'apply', '--yes', '--restore-bar-position', '--live')
        self.assertEqual(status, 3)
        self.assertIn('live input preference drift', output)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.health.call_count, 1)
        self.assertEqual(self.health.call_args.args[0][0], 'hyprctl')

    def test_live_checks_are_explicit_and_read_only(self):
        before = self.snapshot()
        self.health.return_value = subprocess.CompletedProcess(
            [], 0, stdout=json.dumps({'bool': True}), stderr='')
        self.assertEqual(self.runbook('check', '--live')[0], 0)
        for call in self.health.call_args_list:
            self.assertEqual(call.args[0][:3], ['hyprctl', '-j', 'getoption'])
        self.health.return_value.stdout = json.dumps({'bool': False})
        status, output = self.runbook('check', '--live')
        self.assertEqual(status, 3)
        self.assertIn('live input preference drift', output)
        self.assertEqual(self.snapshot(), before)


class InputDeclarationTests(unittest.TestCase):
    def test_lua_declares_only_the_two_health_checked_input_preferences(self):
        # Native Lua parser/execution with a stub hl.config, not a compositor
        # reload. Live Hyprland/Lua integration still needs approved activation.
        if not shutil.which('lua'):
            self.skipTest('Lua is unavailable; declaration check blocked')
        script = '''
local calls = 0
hl = { config = function(config)
  calls = calls + 1
  assert(config.input.natural_scroll == true)
  assert(config.input.touchpad.natural_scroll == true)
  local function count(table)
    local total = 0
    for _ in pairs(table) do total = total + 1 end
    return total
  end
  assert(count(config) == 1)
  assert(count(config.input) == 2)
  assert(count(config.input.touchpad) == 1)
end }
dofile(arg[1])
assert(calls == 1)
'''
        result = subprocess.run(
            ['lua', '-', str(ROOT / 'omarchy/dot-config/hypr/preferences.lua')],
            input=script, text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)
