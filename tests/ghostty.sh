#!/bin/bash
# Ghostty ownership checks use a disposable home, never live activation.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
command -v stow >/dev/null
REPO_ROOT=$ROOT
# shellcheck source=../lib/dotfiles/modules.sh
. "$ROOT/lib/dotfiles/modules.sh"
list_modules darwin | grep '^ghostty|standard|darwin|' >/dev/null
if list_modules omarchy | grep '^ghostty|' >/dev/null; then
  printf 'not ok - Ghostty must remain macOS-only\n' >&2
  exit 1
fi
printf 'ok - Ghostty is selected only on macOS\n'
python3 - "$ROOT" <<'PY'
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='dotfiles-ghostty-') as temp:
    temp = Path(temp)
    repo, home = temp / 'repo', temp / 'home'
    repo.mkdir()
    home.mkdir()
    shutil.copytree(root / 'ghostty', repo / 'ghostty')
    environment = {**os.environ, 'HOME': str(home)}
    target = home / '.config/ghostty/config'
    target.parent.mkdir(parents=True)
    local = home / 'Library/Application Support/com.mitchellh.ghostty/config'
    local.parent.mkdir(parents=True)
    local.write_text('shell-integration-features = ssh-terminfo,ssh-env\n')
    unrelated = target.parent / 'local-file'
    unrelated.write_text('keep me\n')

    def stow(action, success=True):
        result = subprocess.run([
            'stow', '--dir=' + str(repo), '--target=' + str(home),
            '--dotfiles', '--ignore=^(AGENT[.]md|README.*)$', action, 'ghostty',
        ], env=environment, capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stderr

    # A regular config must never be adopted or overwritten.
    target.write_text('unmanaged\n')
    stow('--stow', success=False)
    assert target.read_text() == 'unmanaged\n'
    assert unrelated.read_text() == 'keep me\n'
    target.unlink()
    print('ok - unmanaged Ghostty config conflicts without modification')

    source = (repo / 'ghostty/dot-config/ghostty/config').resolve()
    assert source.read_text().splitlines() == [
        'font-family = "JetBrains Mono"',
        'font-size = 14',
        'theme = dark:"TokyoNight Storm",light:"Rose Pine Dawn"',
        'window-decoration = false',
        'window-padding-x = 0',
        'window-padding-y = 0',
    ]
    stow('--stow')
    stow('--restow')
    stow('--restow')
    assert target.is_symlink() and target.resolve() == source
    assert not (home / 'AGENT.md').exists()
    assert local.read_text().startswith('shell-integration-features = ')
    print('ok - initial Stow and repeated restow resolve to exact source')

    stow('--delete')
    assert not target.exists() and not target.is_symlink()
    assert unrelated.read_text() == 'keep me\n'
    assert local.read_text() == (
        'shell-integration-features = ssh-terminfo,ssh-env\n')
    print('ok - unstow preserves unrelated and macOS-local configuration')

    # Standard folding also supports a whole-directory symlink.
    unrelated.unlink()
    target.parent.rmdir()
    stow('--stow')
    assert target.parent.is_symlink()
    assert target.resolve() == source
    stow('--restow')
    assert target.resolve() == source
    stow('--delete')
    assert not target.parent.is_symlink()
    assert local.is_file()
    print('ok - folded directory ownership survives restow and unstow')
PY
