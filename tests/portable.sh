#!/bin/bash
# Full retained package layout in a disposable home, never a live activation.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
command -v stow >/dev/null
REPO_ROOT=$ROOT
# shellcheck source=../lib/dotfiles/modules.sh
. "$ROOT/lib/dotfiles/modules.sh"
selected=$(list_modules omarchy | cut -d '|' -f 1 | paste -sd ' ' -)
test "$selected" = 'agents codex git omarchy pi tmux'
printf 'ok - Omarchy selection excludes macOS shells and Neovim\n'
python3 - "$ROOT" <<'PY'
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='dotfiles-portable-') as temp:
    temp = Path(temp)
    repo, home = temp / 'repo', temp / 'home'
    repo.mkdir()
    home.mkdir()
    environment = {**os.environ, 'HOME': str(home)}
    packages = sorted(p.parent.name for p in root.glob('*/AGENT.md'))
    for package in packages:
        shutil.copytree(root / package, repo / package, symlinks=True)
    unmanaged = ('.pi/agent/auth.json', '.codex/config.toml',
                 '.agents/skills/dottie/SKILL.md', '.config/nvim-local/file',
                 '.config/herdr/config.toml')
    for relative in unmanaged:
        path = home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('unmanaged\n')

    def stow(package, action='--restow', success=True):
        args = ['stow', '--dir=' + str(repo), '--target=' + str(home),
                '--dotfiles', '--ignore=^(AGENT[.]md|README.*|[.]gitignore|'
                'knowledge-base-skill-adapter)$', action]
        if package in ('agents', 'codex', 'pi'):
            args.append('--no-folding')
        result = subprocess.run(args + [package], env=environment,
                                capture_output=True, text=True)
        assert (result.returncode == 0) == success, result.stderr

    # A new managed target may not overwrite an unmanaged file.
    conflict = home / '.bashrc'
    conflict.write_text('keep me\n')
    stow('bash', '--simulate', success=False)
    assert conflict.read_text() == 'keep me\n'
    conflict.unlink()
    for package in packages:
        declaration = (repo / package / 'AGENT.md').read_text()
        if 'stow none\n' in declaration:
            continue
        stow(package)
        stow(package)
    assert not (home / 'AGENT.md').exists()
    assert not (home / 'README.md').exists()
    for harness in ('.codex', '.pi/agent'):
        instructions = home / harness / 'AGENTS.md'
        assert instructions.resolve() == repo / 'agents/AGENTS.md'
        assert 'TNEZDEV_KNOWLEDGE_BASE_ROOT' in instructions.read_text()
    for path in (repo / 'pi/dot-pi/agent').glob('*.json'):
        json.loads(path.read_text())
    with (repo / 'codex/dot-codex/config.base.toml').open('rb') as file:
        config = tomllib.load(file)
    assert config['approval_policy'] == 'on-request'
    assert config['sandbox_mode'] == 'workspace-write'
    # Validate every retained Stow leaf's exact resolved target.
    for package in packages:
        for source in (repo / package).rglob('*'):
            if source.is_dir() or source.name in (
                'AGENT.md', 'README.md', '.gitignore',
                'knowledge-base-skill-adapter'):
                continue
            relative = source.relative_to(repo / package)
            if not relative.parts[0].startswith('dot-'):
                continue
            target = home.joinpath(*(
                '.' + part[4:] if part.startswith('dot-') else part
                for part in relative.parts))
            assert target.resolve() == source.resolve(), (target, source)
    assert (home / '.codex/config.toml').read_text() == 'unmanaged\n'
    print('ok - retained packages restow; targets and instructions resolve')
    for package in reversed(packages):
        if 'stow none\n' not in (repo / package / 'AGENT.md').read_text():
            stow(package, '--delete')
    for relative in unmanaged:
        assert (home / relative).read_text() == 'unmanaged\n'
    assert not (home / '.pi/agent/AGENTS.md').is_symlink()
    print('ok - unstow preserves unmanaged state, Dottie and retired configs')
PY
