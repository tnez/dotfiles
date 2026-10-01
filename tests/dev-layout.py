#!/usr/bin/env python3
"""Native terminal sizing/client tests; private tmux, inert editor and agent."""

import fcntl
import os
from pathlib import Path
import pty
import shlex
import shutil
import signal
import struct
import subprocess
import tempfile
import termios
import time

ROOT = Path(__file__).resolve().parents[1]
DEV = ROOT / 'omarchy/dot-local/bin/dev'
TMUX = shutil.which('tmux')
if not TMUX:
    raise SystemExit('BLOCKED: tmux is unavailable')

with tempfile.TemporaryDirectory(prefix='dotfiles-dev-layout-') as temporary:
    base = Path(temporary)
    home, binary = base / 'home', base / 'bin'
    home.mkdir()
    binary.mkdir()
    socket = str(base / 'socket')
    config = base / 'tmux.conf'
    config.write_text(
        'set -g default-shell /bin/bash\n'
        'set -g default-command "exec /bin/bash --noprofile --norc"\n'
    )
    env = {**os.environ, 'HOME': str(home), 'SHELL': '/bin/bash',
           'PATH': f'{binary}:/usr/bin:/bin', 'TERM': 'xterm-256color',
           'XDG_CONFIG_HOME': str(base / 'config'),
           'XDG_DATA_HOME': str(base / 'data'),
           'XDG_STATE_HOME': str(base / 'state')}
    for key in ('TMUX', 'TMUX_PANE'):
        env.pop(key, None)
    command = [TMUX, '-S', socket, '-f', str(config)]
    wrapper = binary / 'tmux'
    wrapper.write_text('#!/bin/bash\nexec ' + shlex.join(command) + ' "$@"\n')
    wrapper.chmod(0o755)
    log = base / 'calls'
    for name in ('nvim', 'pi'):
        path = binary / name
        path.write_text(
            '#!/bin/bash\n'
            f'printf \'{name}|%s\\n\' "$PWD" >> {shlex.quote(str(log))}\n'
            'exec sleep 300\n'
        )
        path.chmod(0o755)
    clients = []

    def tm(*args):
        return subprocess.check_output(
            command + list(args), env=env, text=True, timeout=5,
            stderr=subprocess.PIPE).strip()

    def drain():
        for _, master in clients:
            try:
                while os.read(master, 65536):
                    pass
            except (BlockingIOError, OSError):
                pass

    def wait(predicate, description):
        for _ in range(100):
            drain()
            try:
                if predicate():
                    return
            except subprocess.CalledProcessError:
                pass  # server/session may not exist yet
            time.sleep(0.05)
        raise AssertionError('timed out: ' + description)

    def spawn(cols, rows, argv, cwd=None):
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ,
                    struct.pack('HHHH', rows, cols, 0, 0))
        os.set_blocking(master, False)
        try:
            process = subprocess.Popen(
                argv, cwd=cwd, env=env, stdin=slave, stdout=slave,
                stderr=slave, start_new_session=True)
        finally:
            os.close(slave)
        clients.append((process, master))
        return process, master

    def owned(project):
        for row in tm('list-sessions', '-F',
                      '#{session_id}|#{@dev_workflow_root}|'
                      '#{@dev_workflow_ready}').splitlines():
            sid, root, ready = row.split('|')
            if root == str(project) and ready == '1':
                return sid
        return None

    def new_project(name, cols, rows):
        project = base / name
        project.mkdir()
        client = spawn(cols, rows, [str(DEV)], project)
        wait(lambda: owned(project), 'new project ready')
        sid = owned(project)
        wait(lambda: sid in tm('list-clients', '-F',
                              '#{session_id}').splitlines(), 'client attached')
        return project, sid, client

    def panes(sid):
        return [row.split('|') for row in tm(
            'list-panes', '-s', '-t', sid, '-F',
            '#{window_name}|#{pane_id}|#{pane_left}|#{pane_top}|'
            '#{pane_width}|#{pane_height}').splitlines()]

    def check_layout(project, sid, cols, rows, agent_width, shell_pane):
        expected_names = {'dev'}
        if not agent_width:
            expected_names.add('agent')
        if not shell_pane:
            expected_names.add('shell')
        windows = tm('list-windows', '-t', sid, '-F',
                     '#{window_name}|#{window_width}|#{window_height}|'
                     '#{automatic-rename}|#{window-size}').splitlines()
        assert {w.split('|')[0] for w in windows} == expected_names, windows
        for window in windows:
            name, width, height, rename, sizing = window.split('|')
            assert (int(width), int(height)) == (cols, rows), window
            assert rename == '0', window
            assert sizing == 'latest', window
        layout = panes(sid)
        assert len(layout) == 3, layout
        main = [p for p in layout if p[0] == 'dev']
        editor = next(p for p in main if p[2:4] == ['0', '0'])
        expected_width = cols - agent_width - 1 if agent_width else cols
        expected_height = rows - 16 if shell_pane else rows
        assert list(map(int, editor[4:])) == [expected_width, expected_height]
        if agent_width:
            agent = next(p for p in main if int(p[2]) > 0)
            assert list(map(int, agent[4:])) == [agent_width, expected_height]
        if shell_pane:
            shell = next(p for p in main if int(p[3]) > 0)
            assert list(map(int, shell[4:])) == [cols, 15]
        assert tm('display-message', '-p', '-t', sid,
                  '#{window_name}|#{pane_id}') == f'dev|{editor[1]}'
        wait(lambda: log.exists() and all(
            f'{name}|{project}\n' in log.read_text()
            for name in ('nvim', 'pi')),
            'inert editor and agent started in project')
        assert set(tm('list-panes', '-s', '-t', sid, '-F',
                      '#{pane_current_path}').splitlines()) == {str(project)}

    def snapshot(sid):
        return tm('list-panes', '-s', '-t', sid, '-F',
                  '#{window_id}|#{window_layout}|#{pane_id}|#{pane_pid}')

    def enter_from_shell(sid, project):
        shell = next(p for p in panes(sid) if int(p[3]) > 0)
        tm('select-pane', '-t', shell[1])
        marker = base / f'done-{time.monotonic_ns()}'
        line = (f'cd {shlex.quote(str(project))} && '
                f'env PATH={shlex.quote(env["PATH"])} {shlex.quote(str(DEV))}'
                f' && : > {shlex.quote(str(marker))}')
        tm('send-keys', '-t', shell[1], '-l', line)
        tm('send-keys', '-t', shell[1], 'Enter')
        # File acknowledgement stays reliable even in a one-row resized pane.
        wait(marker.exists, 'launcher returned successfully to invoking shell')
        return shell[1]

    try:
        # Keep a fixture session so global options survive between cases.
        tm('new-session', '-d', '-s', 'fixture', 'sleep 300')
        cases = [
            (221, 67, 'on', 100, True),
            (201, 67, 'on', 80, True),
            (220, 67, 'on', 99, True),
            (200, 67, 'on', 0, True),
            (221, 66, 'on', 100, False),
            (200, 66, 'on', 0, False),
            (80, 24, 'on', 0, False),
            (221, 67, '2', 100, False),
            (221, 66, 'off', 100, True),
        ]
        for index, (cols, rows, status, agent, shell) in enumerate(cases):
            tm('set-option', '-g', 'status', status)
            project, sid, (process, _) = new_project(
                f'outside-{index}', cols, rows)
            status_rows = {'on': 1, 'off': 0, '2': 2}[status]
            check_layout(project, sid, cols, rows - status_rows, agent, shell)
            tm('kill-session', '-t', sid)
            process.wait(timeout=5)
        print('ok - native outside attach: layouts, thresholds, status rows')

        tm('set-option', '-g', 'status', 'on')
        project, origin, (client, master) = new_project('origin', 300, 100)
        check_layout(project, origin, 300, 99, 100, True)
        # A second, smaller client must not supply the first client's dimensions
        # or be switched when dev runs from the first client's tiny bottom pane.
        tm('new-session', '-d', '-s', 'other', 'sleep 300')
        other, _ = spawn(90, 30, command + ['attach-session', '-t', 'other'])
        wait(lambda: len(tm('list-clients', '-F',
                            '#{client_name}').splitlines()) == 2,
             'two clients attached')
        inside = base / 'inside'
        inside.mkdir()
        enter_from_shell(origin, inside)
        wait(lambda: owned(inside), 'inside project ready')
        sid = owned(inside)
        wait(lambda: sid in tm('list-clients', '-F',
                              '#{session_id}').splitlines(), 'client switched')
        check_layout(inside, sid, 300, 99, 100, True)
        destinations = tm('list-clients', '-F', '#{session_name}').splitlines()
        assert 'other' in destinations
        print('ok - native inside entry uses whole invoking client only')

        agent = next(p for p in panes(sid) if int(p[2]) > 0)
        tm('resize-pane', '-t', agent[1], '-x', '91')
        before = snapshot(sid)
        shell = enter_from_shell(sid, inside)
        assert snapshot(sid) == before
        print('ok - native re-entry preserves custom layout and pane processes')

        fcntl.ioctl(master, termios.TIOCSWINSZ,
                    struct.pack('HHHH', 40, 160, 0, 0))
        client.send_signal(signal.SIGWINCH)
        wait(lambda: tm('display-message', '-p', '-t', sid,
                        '#{window_width}x#{window_height}') == '160x39',
             'ordinary tmux terminal resize')
        assert tm('list-windows', '-t', sid, '-F', '#{window_name}') == 'dev'
        before = snapshot(sid)
        tm('clear-history', '-t', shell)
        enter_from_shell(sid, inside)
        assert snapshot(sid) == before
        assert tm('list-windows', '-t', sid, '-F', '#{window_name}') == 'dev'
        print('ok - resize and re-entry do not migrate panes into windows')
    finally:
        subprocess.run(command + ['kill-server'], env=env,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for process, master in clients:
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.terminate()
                process.wait(timeout=5)
            os.close(master)
