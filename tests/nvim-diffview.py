#!/usr/bin/env python3
"""Native Diffview/Lazy smoke check in a disposable, divergent Git repo.

Needs installed Neovim, Diffview and Lazy checkouts; never downloads plugins.
DIFFVIEW_PATH and LAZY_PATH can select reviewed checkouts. This exercises only
this Git plugin spec, not the full Neovim distribution or a live tmux session.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
DATA = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share'))
PLUGIN = Path(os.environ.get('DIFFVIEW_PATH', DATA / 'nvim/lazy/diffview.nvim'))
LAZY = Path(os.environ.get('LAZY_PATH', DATA / 'nvim/lazy/lazy.nvim'))
for tool in ('git', 'nvim'):
    if not shutil.which(tool):
        sys.exit(f'BLOCKED: {tool} is unavailable')
for path in (PLUGIN / 'plugin/diffview.lua', LAZY / 'lua/lazy/init.lua'):
    if not path.is_file():
        sys.exit(f'BLOCKED: missing plugin file: {path}')

with tempfile.TemporaryDirectory(prefix='nvim-diffview-') as directory:
    temp = Path(directory)
    repo = temp / 'repo'
    repo.mkdir()
    env = {k: v for k, v in os.environ.items()
           if k not in ('TMUX', 'TMUX_PANE', 'VIMINIT', 'EXINIT')}
    env.update(HOME=directory, XDG_CONFIG_HOME=str(temp / 'config'),
               XDG_DATA_HOME=str(temp / 'data'),
               XDG_STATE_HOME=str(temp / 'state'),
               XDG_CACHE_HOME=str(temp / 'cache'),
               GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)

    def git(*args):
        return subprocess.check_output(
            ['git', *args], cwd=repo, env=env, text=True).strip()

    def commit(message):
        git('add', '.')
        git('-c', 'user.name=Fixture', '-c', 'user.email=test@example.invalid',
            'commit', '-qm', message)

    git('init', '-q', '-b', 'main')
    (repo / 'changed.txt').write_text('base\n')
    (repo / 'deleted.txt').write_text('delete me\n')
    commit('base')
    base = git('rev-parse', 'HEAD')
    git('checkout', '-qb', 'review')
    (repo / 'changed.txt').write_text('branch\n')
    (repo / 'added.txt').write_text('added\n')
    (repo / 'deleted.txt').unlink()
    commit('review changes')
    head = git('rev-parse', 'HEAD')
    git('checkout', '-q', 'main')
    (repo / 'base-only.txt').write_text('not a PR change\n')
    commit('divergent main')
    git('update-ref', 'refs/remotes/origin/main', 'HEAD')
    git('checkout', '-q', 'review')
    (repo / 'changed.txt').write_text('uncommitted; must not be reviewed\n')
    (repo / 'untracked.txt').write_text('preserve me\n')
    before = git('status', '--porcelain=v1')
    index = git('write-tree')
    spec_path = ROOT / 'nvim/dot-config/nvim/lua/plugins/git.lua'

    init = temp / 'init.lua'
    init.write_text(f'''
vim.g.mapleader = ' '
vim.opt.rtp:prepend({json.dumps(str(LAZY))})
local spec
for _, candidate in ipairs(dofile({json.dumps(str(spec_path))})) do
  if candidate[1] == 'sindrets/diffview.nvim' then spec = candidate end
end
assert(spec, 'Diffview spec is missing')
spec.dir = {json.dumps(str(PLUGIN))}
require('lazy').setup({{ spec }}, {{
  root = {json.dumps(str(temp / 'plugins'))},
  lockfile = {json.dumps(str(temp / 'lazy-lock.json'))},
  install = {{ missing = false }},
  checker = {{ enabled = false }},
  change_detection = {{ enabled = false }},
  readme = {{ enabled = false }},
}})
''')
    checks = temp / 'checks.lua'
    checks.write_text(f'''
local ok, err = pcall(function()
  local lib = require('diffview.lib')
  assert(vim.wait(10000, function()
    local view = lib.get_current_view()
    return view and view.files:len() == 3 and view.cur_layout
      and view.cur_layout.a and view.cur_layout.a.file
      and view.cur_layout.a.file.bufnr
  end, 20), 'Diffview did not load three changed files')
  local view = lib.get_current_view()
  assert(view.left.commit == '{base}', 'Left side is not the merge base')
  assert(view.right.commit == '{head}', 'Right side is not committed HEAD')
  local paths = {{}}
  for _, file in view.files:iter() do paths[#paths + 1] = file.path end
  table.sort(paths)
  assert(vim.deep_equal(paths, {{ 'added.txt', 'changed.txt', 'deleted.txt' }}),
    vim.inspect(paths))
  assert(view.panel:is_open(), 'Changed-file sidebar is closed')
  assert(vim.wait(10000, function()
    local layout = view.cur_layout
    return layout.a:is_valid() and layout.b:is_valid()
      and vim.wo[layout.a.id].diff and vim.wo[layout.b.id].diff
  end, 20), 'Both diff windows must be open')
  local a = vim.api.nvim_win_get_position(view.cur_layout.a.id)
  local b = vim.api.nvim_win_get_position(view.cur_layout.b.id)
  assert(a[1] == b[1] and a[2] < b[2], 'Diff is not side-by-side')
  vim.api.nvim_feedkeys(' gD', 'xt', false)
  assert(vim.wait(5000, function() return #lib.views == 0 end, 20),
    'Close binding left an open Diffview')
  assert(#vim.api.nvim_list_tabpages() == 1, 'Close left a review tab')
  local opened = pcall(vim.cmd, 'DiffviewOpen origin/missing-base...HEAD')
  assert(not opened, 'Missing base should report a revision error')
  assert(#lib.views == 0, 'Missing base must not fall back to local diff')
  vim.cmd('DiffviewOpen HEAD...HEAD')
  assert(vim.wait(5000, function()
    local empty = lib.get_current_view()
    return empty and empty.ready and empty.files:len() == 0
  end, 20), 'Empty range failed to open')
  vim.cmd('DiffviewClose')
  assert(#lib.views == 0, 'Empty range did not close')
end)
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd('cquit 1')
end
print('ok - three-dot refs, sidebar, side-by-side windows, close binding')
vim.cmd('qa!')
''')
    for label, command in (
        ('keybinding', "lua vim.api.nvim_feedkeys(' gd', 'xt', false)"),
        ('shell launcher', 'DiffviewOpen origin/main...HEAD'),
    ):
        result = subprocess.run(
            ['nvim', '--headless', '-i', 'NONE', '-u', str(init),
             '-c', command, '-c', f'lua dofile({json.dumps(str(checks))})'],
            cwd=repo, env=env, text=True, capture_output=True, timeout=30)
        print(f'{label}: {result.stdout}{result.stderr}')
        assert result.returncode == 0, f'{label} failed'
        assert git('status', '--porcelain=v1') == before
        assert git('write-tree') == index
        assert git('rev-parse', 'HEAD') == head
        assert (repo / 'changed.txt').read_text().startswith('uncommitted;')
        assert (repo / 'untracked.txt').read_text() == 'preserve me\n'
    print('ok - dirty tracked/untracked files and index preserved')
