#!/usr/bin/env python3
"""Real prefix keypresses on a private server; only inert fixture processes."""
import fcntl
import os
from pathlib import Path
import pty
import shutil
import struct
import subprocess
import tempfile
import termios
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
TMUX = shutil.which('tmux')
if not TMUX:
    raise SystemExit('BLOCKED: tmux is unavailable')


def wait_for(predicate, description):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.03)
    raise AssertionError(description)


with tempfile.TemporaryDirectory(prefix='tmux-session-controls-') as directory:
    base = Path(directory).resolve()
    home = base / 'home'
    home.mkdir()
    project = base / 'project with spaces'
    project.mkdir()
    socket = str(base / 'socket')
    config = base / 'fixture.conf'
    config.write_text('set -g default-shell /bin/sh\n'
                      'set -g default-command "exec sleep 120"\n'
                      'set -g history-limit 2000\n')
    # On Linux, model the externally owned Omarchy defaults. Darwin must obtain
    # these bindings from the personal config, without loading this fixture.
    omarchy = base / 'omarchy'
    stock = omarchy / 'config/tmux/tmux.conf'
    stock.parent.mkdir(parents=True)
    stock.write_text('bind k kill-window\nbind K kill-session\n'
                     'bind C new-session -c "#{pane_current_path}"\n'
                     'bind P switch-client -p\nbind N switch-client -n\n'
                     'set -g detach-on-destroy off\n'
                     'set -g history-limit 50000\n')
    env = {k: v for k, v in os.environ.items()
           if k not in ('TMUX', 'TMUX_PANE', 'XDG_CONFIG_HOME', 'TMUX_TMPDIR')}
    env.update(HOME=str(home), TERM='xterm-256color', SHELL='/bin/sh',
               OMARCHY_PATH=str(omarchy), XDG_CONFIG_HOME=str(home / '.config'))
    command = [TMUX, '-S', socket, '-f', str(config)]

    def tm(*args):
        return subprocess.check_output(command + list(args), env=env,
                                       text=True, stderr=subprocess.PIPE,
                                       timeout=5).strip()

    def sessions():
        return set(tm('list-sessions', '-F', '#{session_id}').splitlines())

    def windows():
        return set(tm('list-windows', '-a', '-F', '#{window_id}').splitlines())

    def snapshot(session):
        return tm('list-panes', '-s', '-t', session, '-F',
                  '#{window_id}|#{pane_id}|#{pane_pid}|#{pane_current_path}')

    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 160, 0, 0))
    client_name = os.ttyname(slave)
    client = None
    drainer = None

    def current():
        rows = tm('list-clients', '-F',
                  '#{client_name}|#{session_id}').splitlines()
        return next((row.split('|')[1] for row in rows
                     if row.split('|')[0] == client_name), None)

    def press(key, predicate, description):
        os.write(master, b'\x02' + key.encode())  # C-b fallback prefix
        wait_for(predicate, description)
        print('ok -', description)

    try:
        anchor = tm('new-session', '-d', '-P', '-F', '#{session_id}',
                    '-s', 'anchor', '-c', str(project),
                    'printf "preserved-scrollback\\n"; exec sleep 120')
        old_pane = tm('display-message', '-p', '-t', anchor, '#{pane_id}')
        wait_for(lambda: 'preserved-scrollback' in tm(
            'capture-pane', '-p', '-t', old_pane), 'fixture output appears')
        assert tm('show-options', '-gqv', 'history-limit') == '2000'
        tm('source-file', str(ROOT / 'tmux/dot-config/tmux/tmux.conf'))
        assert tm('show-options', '-gqv', 'history-limit') == '50000'
        assert 'preserved-scrollback' in tm(
            'capture-pane', '-p', '-S', '-', '-t', old_pane)
        other = tm('new-session', '-d', '-P', '-F', '#{session_id}',
                   '-s', 'other', '-c', str(home))
        other_before = snapshot(other)
        victim = tm('new-window', '-t', anchor + ':', '-n', 'victim',
                    '-P', '-F', '#{window_id}', '-c', str(project))
        tm('split-window', '-d', '-t', victim)
        assert tm('display-message', '-p', '-t', victim,
                  '#{history_limit}') == '50000'
        print('ok - 50,000-line limit with existing scrollback preserved')

        client = subprocess.Popen(command + ['attach-session', '-t', anchor],
                                  env=env, stdin=slave, stdout=slave,
                                  stderr=slave)

        def drain():
            try:
                while os.read(master, 65536):
                    pass
            except OSError:
                pass

        drainer = threading.Thread(target=drain, daemon=True)
        drainer.start()
        wait_for(lambda: current() == anchor, 'fixture client attaches')
        press('k', lambda: victim not in windows(),
              'prefix+k immediately kills the whole current window')
        assert anchor in sessions() and snapshot(other) == other_before

        before = sessions()
        press('C', lambda: current() not in before and current() is not None,
              'prefix+C creates and enters a new session')
        created = current()
        assert sessions() - before == {created}
        assert tm('display-message', '-p', '-t', created,
                  '#{pane_current_path}') == str(project)
        print('ok - new session inherits the pane directory, including spaces')
        press('P', lambda: current() in before,
              'prefix+P switches to the previous session')
        press('N', lambda: current() == created,
              'prefix+N switches back to the next session')

        # Prove K removes the whole session, not just its active pane/window.
        tm('split-window', '-d', '-t', created)
        tm('new-window', '-d', '-t', created + ':', '-c', str(project))
        preserved = {session: snapshot(session) for session in before}
        press('K', lambda: created not in sessions(),
              'prefix+K immediately kills the whole current session')
        wait_for(lambda: current() in before, 'client remains on a survivor')
        assert sessions() == before
        assert {session: snapshot(session) for session in before} == preserved
        assert client.poll() is None
        print('ok - other sessions, windows, pane IDs/PIDs and client survive')
    finally:
        subprocess.run(command + ['kill-server'], env=env, capture_output=True,
                       timeout=5)
        if client:
            try:
                client.wait(timeout=5)
            except subprocess.TimeoutExpired:
                client.kill()
                client.wait(timeout=5)
        os.close(slave)
        os.close(master)
        if drainer:
            drainer.join(timeout=2)
