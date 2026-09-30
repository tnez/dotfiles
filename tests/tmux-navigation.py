#!/usr/bin/env python3
"""Native keypress smoke test; needs an installed smart-splits checkout.

SMART_SPLITS_PATH may point to a reviewed checkout.
No downloads or live reloads.
This tests the plugin/spec and tmux, not the complete LazyVim distribution.
"""
import fcntl
import json
import os
from pathlib import Path
import pty
import shutil
import struct
import subprocess
import sys
import tempfile
import termios
import threading
import time

ROOT = Path(__file__).resolve().parent.parent
PLUGIN = Path(os.environ.get(
    'SMART_SPLITS_PATH',
    str(Path.home() / '.local/share/nvim/lazy/smart-splits.nvim'),
))
for tool in ('tmux', 'nvim'):
    if not shutil.which(tool):
        print(f'BLOCKED: {tool} is unavailable', file=sys.stderr)
        raise SystemExit(2)
if not (PLUGIN / 'lua/smart-splits/init.lua').exists():
    print('BLOCKED: set SMART_SPLITS_PATH to an installed checkout',
          file=sys.stderr)
    raise SystemExit(2)


def wait_for(predicate, description):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.05)
    raise AssertionError(description)


with tempfile.TemporaryDirectory(prefix='navigation-') as directory:
    temp = Path(directory)
    env = {k: v for k, v in os.environ.items()
           if k not in ('TMUX', 'TMUX_PANE', 'VIMINIT', 'EXINIT')}
    env.update(HOME=directory, TERM='xterm-256color',
               XDG_CONFIG_HOME=str(temp / 'config'),
               XDG_DATA_HOME=str(temp / 'data'),
               XDG_STATE_HOME=str(temp / 'state'),
               XDG_CACHE_HOME=str(temp / 'cache'))
    socket = str(temp / 'tmux')
    rpc = str(temp / 'nvim')
    spec = ROOT / 'omarchy/dot-config/nvim/lua/plugins/smart-splits.lua'
    init = temp / 'init.lua'
    init.write_text(f'''
vim.opt.rtp:prepend({json.dumps(str(PLUGIN))})
local spec = dofile({json.dumps(str(spec))})[1]
require('smart-splits').setup(spec.opts)
for _, key in ipairs(spec.keys) do
  vim.keymap.set('n', key[1], key[2], {{ desc = key.desc }})
end
vim.cmd('vsplit')
vim.cmd('wincmd h')
''')

    def tmux(*args):
        return subprocess.check_output(
            ['tmux', '-S', socket, *args], env=env, text=True).strip()

    def expression(expr):
        result = subprocess.run(
            ['nvim', '--server', rpc, '--remote-expr', expr], env=env,
            capture_output=True, text=True, timeout=5)
        return result.stdout.strip() if result.returncode == 0 else ''

    def active():
        return tmux('display-message', '-p', '#{pane_id}')

    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 160, 0, 0))
    client = None
    try:
        editor = tmux('-f', '/dev/null', 'new-session', '-d', '-P',
                      '-F', '#{pane_id}', '-s', 'test', '-x', '160', '-y', '40',
                      'nvim', '-i', 'NONE', '-u', str(init), '--listen', rpc)
        tmux('set-option', '-g', 'remain-on-exit', 'on')
        tmux('source-file', str(ROOT / 'tmux/dot-tmux.conf'))
        shell = tmux('split-window', '-h', '-d', '-P', '-F', '#{pane_id}',
                     'sleep', '120')
        client = subprocess.Popen(
            ['tmux', '-S', socket, 'attach-session', '-t', 'test'],
            env=env, stdin=slave, stdout=slave, stderr=slave)

        # Drain rendering so the attached client never blocks on a full PTY.
        def drain():
            try:
                while os.read(master, 65536):
                    pass
            except OSError:
                pass

        threading.Thread(target=drain, daemon=True).start()
        wait_for(lambda: tmux('show-options', '-pqv', '-t', editor,
                              '@pane-is-vim') == '1', 'Neovim pane marker')
        wait_for(lambda: expression('winnr()') == '1', 'Neovim startup')

        def press(key, predicate, description):
            os.write(master, bytes([ord(key) - ord('a') + 1]))
            wait_for(predicate, description)
            print('ok -', description)

        press('l', lambda: expression('winnr()') == '2' and active() == editor,
              'Ctrl-l moves inside Neovim')
        press('l', lambda: active() == shell,
              'Ctrl-l crosses from Neovim into tmux')
        press('h', lambda: active() == editor,
              'Ctrl-h returns from tmux into Neovim')
        press('h', lambda: expression('winnr()') == '1',
              'Ctrl-h moves inside Neovim')

        tmux('select-layout', 'even-vertical')
        expression("execute('only | split | wincmd k')")
        press('j', lambda: expression('winnr()') == '2' and active() == editor,
              'Ctrl-j moves inside Neovim')
        press('j', lambda: active() == shell,
              'Ctrl-j crosses from Neovim into tmux')
        press('k', lambda: active() == editor,
              'Ctrl-k returns from tmux into Neovim')
        press('k', lambda: expression('winnr()') == '1',
              'Ctrl-k moves inside Neovim')
        expression("execute('qa!')")
        wait_for(lambda: tmux('show-options', '-pqv', '-t', editor,
                              '@pane-is-vim') == '0', 'exit clears pane marker')
        print('ok - Neovim exit clears its pane marker')
    finally:
        subprocess.run(['tmux', '-S', socket, 'kill-server'], env=env,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if client:
            client.wait(timeout=5)
        os.close(slave)
        os.close(master)
