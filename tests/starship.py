#!/usr/bin/env python3
"""Render the real prompt in disposable homes and Git repositories."""

import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / 'starship/dot-config/starship.toml'
ANSI = re.compile(r'\x1b\[[0-9;]*m')
assert shutil.which('starship'), 'starship is required'

with tempfile.TemporaryDirectory(prefix='dotfiles-starship-') as temporary:
    home = Path(temporary).resolve()
    env = {key: value for key, value in os.environ.items()
           if not key.startswith(('GIT_', 'STARSHIP_'))}
    env.update({
        'HOME': str(home),
        'XDG_CONFIG_HOME': str(home / '.config'),
        'STARSHIP_CONFIG': str(CONFIG),
        'STARSHIP_CACHE': str(home / '.cache'),
        'STARSHIP_SHELL': 'sh',
        'GIT_CONFIG_NOSYSTEM': '1',
        'GIT_CONFIG_GLOBAL': os.devnull,
        'LC_ALL': 'C',
    })

    def run(args, cwd):
        result = subprocess.run(args, cwd=cwd, env=env, text=True,
                                capture_output=True, check=True)
        return result.stdout

    def git(cwd, *args):
        return run(['git', *args], cwd).strip()

    def init(path):
        path.mkdir(parents=True)
        git(path, 'init', '-b', 'main')
        git(path, 'config', 'user.name', 'Prompt Test')
        git(path, 'config', 'user.email', 'prompt@example.invalid')
        for name in ('one', 'two', 'three'):
            (path / name).write_text('initial\n')
        git(path, 'add', '.')
        git(path, 'commit', '-m', 'Initial')
        return path

    def prompt(path, *args):
        result = subprocess.run(
            ['starship', 'prompt', '--path', str(path), *args],
            cwd=path, env={**env, 'PWD': str(path)}, text=True,
            capture_output=True, check=True)
        assert not result.stderr, result.stderr
        return result.stdout

    def context(path, *args):
        raw = prompt(path, *args)
        plain = ANSI.sub('', raw)
        lines = plain.split('\n')
        assert len(lines) == 2, repr(plain)
        assert lines[1] == '❯ ', repr(plain)
        host = socket.gethostname().split('.')[0]
        prefix = f'[{host}] '
        assert lines[0].startswith(prefix), repr(plain)
        assert prompt(path, '--right') == '', 'right prompt must be empty'
        return lines[0][len(prefix):].strip()

    main = init(home / 'dotfiles/main')
    assert prompt(main, '--right') == '', 'right prompt must be empty'
    assert context(main) == 'dotfiles/main main', repr(context(main))
    nested = main / 'scripts/nested'
    nested.mkdir(parents=True)
    assert context(nested) == 'dotfiles/main/scripts/nested main'
    print('ok - two left-only lines, hostname, project, full relative path')

    worktree = home / 'dotfiles/fix-prompt'
    git(main, 'worktree', 'add', '-b', 'fix/prompt', str(worktree))
    assert context(worktree) == 'dotfiles/fix-prompt fix/prompt'
    (worktree / 'src').mkdir()
    assert context(worktree / 'src') == 'dotfiles/fix-prompt/src fix/prompt'
    git(worktree, 'checkout', '--detach')
    commit = git(worktree, 'rev-parse', '--short=7', 'HEAD')
    assert context(worktree) == f'dotfiles/fix-prompt @{commit}'
    print('ok - linked worktree identity, branch and detached commit')

    ordinary = init(home / 'widget')
    assert context(ordinary) == 'widget main'
    linked = home / 'elsewhere/review'
    linked.parent.mkdir()
    git(ordinary, 'worktree', 'add', '-b', 'review', str(linked))
    assert context(linked) == 'widget/review review'
    unborn = home / 'unborn'
    unborn.mkdir()
    git(unborn, 'init', '-b', 'main')
    assert context(unborn) == 'unborn main'
    print('ok - ordinary repos, external worktrees and unborn branches')

    downloads = home / 'Downloads'
    downloads.mkdir()
    assert context(downloads) == '~/Downloads'
    assert context(home) == '~'
    # Detected runtimes and cloud environment must not add any modules.
    (downloads / 'bun.lock').write_text('')
    (downloads / 'package.json').write_text('{"name":"test"}')
    env['CLOUDSDK_CORE_PROJECT'] = 'test-project'
    assert context(downloads) == '~/Downloads'
    assert context(main, '--status', '1') == context(main)
    assert '\x1b[1;31m❯' in prompt(main, '--status', '1')
    assert '\x1b[1;32m❯' in prompt(main, '--status', '0')
    assert context(main, '--terminal-width', '40') == 'dotfiles/main main'
    print('ok - non-Git directories, no runtime/cloud, failure color')

    (main / 'one').write_text('modified\n')
    (main / 'two').write_text('staged\n')
    git(main, 'add', 'two')
    (main / 'untracked').write_text('new\n')
    status = context(main)
    for indicator in ('!1', '+1', '?1'):
        assert indicator in status.split(), status
    (main / 'three').unlink()
    assert '✘1' in context(main).split()
    git(main, 'reset', '--hard', 'HEAD')
    (main / 'untracked').unlink()
    git(main, 'mv', 'three', 'renamed')
    assert '»1' in context(main).split()
    git(main, 'reset', '--hard', 'HEAD')
    assert context(main) == 'dotfiles/main main'
    print('ok - staged, modified, untracked, deleted, renamed; clean silence')

    base = git(main, 'rev-parse', 'HEAD')
    git(main, 'config', 'remote.origin.url', str(home / 'unused-remote'))
    git(main, 'config', 'remote.origin.fetch',
        '+refs/heads/*:refs/remotes/origin/*')
    git(main, 'config', 'branch.main.remote', 'origin')
    git(main, 'config', 'branch.main.merge', 'refs/heads/main')
    git(main, 'update-ref', 'refs/remotes/origin/main', base)
    git(main, 'commit', '--allow-empty', '-m', 'Local')
    local = git(main, 'rev-parse', 'HEAD')
    assert '↑1' in context(main).split()
    git(main, 'update-ref', 'refs/remotes/origin/main', local)
    git(main, 'reset', '--hard', base)
    assert '↓1' in context(main).split()
    git(main, 'commit', '--allow-empty', '-m', 'Other')
    status = context(main)
    assert '↑1' in status.split() and '↓1' in status.split(), status
    print('ok - ahead, behind and diverged counts without network access')

    conflict = init(home / 'conflict')
    git(conflict, 'checkout', '-b', 'other')
    (conflict / 'one').write_text('other\n')
    git(conflict, 'commit', '-am', 'Other change')
    git(conflict, 'checkout', 'main')
    (conflict / 'one').write_text('main\n')
    git(conflict, 'commit', '-am', 'Main change')
    merge = subprocess.run(['git', 'merge', 'other'], cwd=conflict,
                           env=env, capture_output=True)
    assert merge.returncode == 1
    assert '=1' in context(conflict).split()
    print('ok - merge conflicts are visible')

print('All Starship tests passed.')
