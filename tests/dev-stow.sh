#!/bin/bash
# Isolated ownership and migration tests, never the live home or tmux server.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
command -v stow >/dev/null
python3 - "$ROOT" <<'PY'
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='dev-stow-') as directory:
    base = Path(directory).resolve()
    repo, home = base / 'repo space', base / 'home'
    repo.mkdir()
    for package in ('dev', 'omarchy'):
        shutil.copytree(root / package, repo / package, symlinks=True)
    binary = home / '.local/bin'
    binary.mkdir(parents=True)
    keep = binary / 'keep'
    keep.write_text('unmanaged command\n')
    env = {**os.environ, 'HOME': str(home)}
    target = binary / 'dev'
    source = repo / 'dev/dot-local/bin/dev'
    legacy = repo / 'omarchy/dot-local/bin/dev'

    def stow(package, action='--restow', success=True):
        args = ['stow', '--dir=' + str(repo), '--target=' + str(home),
                '--dotfiles', '--ignore=^(AGENT[.]md|README.*)$', action]
        if package == 'dev':
            args.append('--no-folding')
        result = subprocess.run(args + [package], env=env, text=True,
                                capture_output=True, timeout=10)
        assert (result.returncode == 0) == success, result.stderr

    target.write_text('local dev\n')
    stow('dev', '--simulate', success=False)
    assert target.read_text() == 'local dev\n'
    target.unlink()
    foreign = base / 'foreign'
    foreign.write_text('foreign command\n')
    target.symlink_to(foreign)
    stow('dev', '--simulate', success=False)
    assert target.resolve() == foreign
    assert foreign.read_text() == 'foreign command\n'
    target.unlink()
    print('ok - shared dev refuses unmanaged commands and foreign links')

    stow('dev', '--stow')
    stow('dev')
    stow('dev')
    assert target.is_symlink() and target.resolve() == source
    assert not binary.is_symlink() and not binary.parent.is_symlink()
    assert not (home / 'AGENT.md').exists()
    result = subprocess.run([str(target), '--help'], env=env, text=True,
                            capture_output=True, timeout=5, check=True)
    assert 'dev resize' in result.stdout
    stow('dev', '--delete')
    assert not target.exists() and not target.is_symlink()
    assert keep.read_text() == 'unmanaged command\n'
    print('ok - exact leaf ownership, repeat restow/help and unstow preservation')

    # A pre-existing Omarchy leaf remains usable through the retained source.
    target.symlink_to(os.path.relpath(legacy, binary))
    old_link = os.readlink(target)
    result = subprocess.run([str(target), '--help'], env=env, text=True,
                            capture_output=True, timeout=5, check=True)
    assert 'dev resize' in result.stdout
    stow('omarchy')
    assert target.is_symlink() and os.readlink(target) == old_link
    stow('dev', '--simulate', success=False)
    assert os.readlink(target) == old_link
    # Explicitly approved fixture migration: replace only the verified leaf.
    assert target.resolve() == legacy
    target.unlink()
    stow('dev', '--simulate')
    stow('dev')
    assert target.resolve() == source
    stow('omarchy')
    stow('omarchy', '--delete')
    assert target.resolve() == source
    stow('dev', '--delete')
    assert not target.exists() and not target.is_symlink()
    assert keep.read_text() == 'unmanaged command\n'
    assert legacy.is_file() and os.access(legacy, os.X_OK)
    print('ok - legacy wrapper survives updates; ownership migration is explicit')
PY
