#!/usr/bin/env python3
"""Retired hooks must not recreate links or mutate settings."""

from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


class RetiredLinks(unittest.TestCase):
    def test_old_mutations_stop_without_changes(self):
        with tempfile.TemporaryDirectory() as home:
            for command in ('repair', 'install-hooks'):
                result = subprocess.run([
                    sys.executable, str(ROOT / 'omarchy-agent-links'),
                    command, '--yes'], env={'HOME': home},
                    capture_output=True, text=True)
                self.assertEqual(result.returncode, 3)
                self.assertIn('ACTION_REQUIRED', result.stderr)
                self.assertEqual(list(Path(home).iterdir()), [])

    def test_check_delegates_to_materialized_state_check(self):
        with patch.object(sys, 'argv', ['omarchy-agent-links', 'check']), \
                patch('os.execv', side_effect=SystemExit(0)) as execute:
            with self.assertRaises(SystemExit):
                runpy.run_path(str(ROOT / 'omarchy-agent-links'),
                               run_name='__main__')
            self.assertEqual(execute.call_args.args[1], [
                sys.executable, str(ROOT / 'agent-config'), 'check'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
