#!/usr/bin/env python3
"""Exercise real popup keypresses on an isolated server; never call a model."""
import fcntl
import json
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

ROOT = Path(__file__).resolve().parent.parent
for tool in ('tmux', 'stow', 'bash'):
    if not shutil.which(tool):
        raise SystemExit(f'BLOCKED: {tool} is unavailable')


def wait_for(predicate, description):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.03)
    raise AssertionError(description)


with tempfile.TemporaryDirectory(prefix='agent-popup-') as directory:
    temp = Path(directory)
    home = temp / "home with 'quotes; $dollars"
    home.mkdir()
    custom_xdg = os.environ.get('TMUX_TEST_XDG') == '1'
    config_home = home / ('custom config' if custom_xdg else '.config')
    config = config_home / 'tmux'
    config.mkdir(parents=True)
    user_config = config / 'tmux.conf'
    user_config.write_text('unmanaged config\n')
    unrelated = config / 'local.conf'
    unrelated.write_text('machine-owned\n')
    helper = config / 'agent-popup'
    helper.write_text('unmanaged helper\n')
    env = {k: v for k, v in os.environ.items()
           if k not in ('TMUX', 'TMUX_PANE', 'XDG_CONFIG_HOME',
                        'XDG_STATE_HOME', 'PI_CODING_AGENT_DIR')}
    env.update(HOME=str(home), SHELL='/bin/sh', TERM='xterm-256color')
    if custom_xdg:
        env['XDG_CONFIG_HOME'] = str(config_home)
    elif os.environ.get('TMUX_TEST_XDG') == 'empty':
        env['XDG_CONFIG_HOME'] = ''

    def stow(action, success=True):
        args = ([shutil.which('stow'),
                 '--dir=' + str(ROOT / 'tmux/dot-config'),
                 '--target=' + str(config)] if custom_xdg else
                [shutil.which('stow'), '--dir=' + str(ROOT),
                 '--target=' + str(home), '--dotfiles',
                 '--ignore=^AGENT[.]md$'])
        result = subprocess.run(args + [action, 'tmux'], env=env,
                                capture_output=True, text=True, timeout=15)
        assert (result.returncode == 0) == success, result.stderr

    stow('--stow', success=False)
    assert helper.read_text() == 'unmanaged helper\n'
    assert user_config.read_text() == 'unmanaged config\n'
    helper.unlink()
    stow('--stow', success=False)
    assert user_config.read_text() == 'unmanaged config\n'
    user_config.unlink()
    stow('--stow')
    stow('--restow')
    assert helper.resolve() == ROOT / 'tmux/dot-config/tmux/agent-popup'
    assert user_config.resolve() == ROOT / 'tmux/dot-config/tmux/tmux.conf'
    assert not (home / '.tmux.conf').exists()
    assert unrelated.read_text() == 'machine-owned\n'
    print('ok - Stow conflict, initial stow, restow and exact helper targets')

    bin_dir = home / 'bin'
    bin_dir.mkdir()
    for tool in ('tmux', 'bash', 'cksum', 'mkdir', 'env', 'uname',
                 'sleep', 'perl', 'dirname'):
        executable = shutil.which(tool)
        if not executable:
            raise SystemExit(f'BLOCKED: {tool} is unavailable')
        (bin_dir / tool).symlink_to(executable)
    # A fake Pi records its process, arguments and inputs. It does not simulate
    # Pi internals: /new below proves input forwarding, not Pi's implementation.
    fake = bin_dir / 'pi'
    fake.write_text(f'''#!{shutil.which('python3')}
import json
import os
from pathlib import Path
import sys
import time
home = Path.home()
with (home / 'launches.jsonl').open('a') as file:
    file.write(json.dumps(dict(pid=os.getpid(), cwd=os.getcwd(),
                               args=sys.argv[1:])) + '\\n')
sys.stderr = (home / 'fake-stderr').open('a', buffering=1)
print('FAKE PI READY', flush=True)
for line in sys.stdin:
    text = line.rstrip('\\n')
    if text == 'work':
        time.sleep(0.3)
    with (home / 'inputs.jsonl').open('a') as file:
        file.write(json.dumps(text) + '\\n')
    print('REPLY ' + text, flush=True)
    if text == 'quit':
        break
''')
    fake.chmod(0o755)
    # No system Pi fallback, even on hosts that install Pi into /usr/bin.
    env['PATH'] = str(bin_dir)
    socket = str(temp / 'tmux')
    target = 'dotfiles-agent'
    clients = []
    helpers = []
    terminal_output = bytearray()

    def tmux(*args):
        return subprocess.check_output(
            [str(bin_dir / 'tmux'), '-S', socket, *args], env=env,
            text=True, timeout=5).strip()

    def records(name):
        path = home / name
        return [json.loads(line) for line in path.read_text().splitlines()] \
            if path.exists() else []

    def attached():
        return tmux('list-clients', '-t', target, '-F', '#{client_name}')

    def attach(session):
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ,
                    struct.pack('HHHH', 40, 160, 0, 0))
        process = subprocess.Popen(
            [str(bin_dir / 'tmux'), '-S', socket, 'attach', '-t', session],
            env=env, stdin=slave, stdout=slave, stderr=slave)
        clients.append((process, master, slave))

        def drain():
            try:
                while chunk := os.read(master, 65536):
                    terminal_output.extend(chunk)
                    del terminal_output[:-32768]
            except OSError:
                pass

        threading.Thread(target=drain, daemon=True).start()
        tty = os.ttyname(slave)
        wait_for(lambda: tty in tmux('list-clients', '-F', '#{client_name}'),
                 'outer client attaches')
        return master, tty

    def press(master, text):
        os.write(master, text)

    try:
        project = home / 'project with spaces; $(touch SHOULD-NOT-EXIST)'
        project.mkdir()
        # No -f: load the stowed XDG entrypoint through native discovery.
        pane = tmux('new-session', '-d', '-P',
                    '-F', '#{pane_id}', '-s', 'first', '-c', str(project),
                    'sleep', '120')
        tmux('set-option', '-g', 'default-shell', '/bin/sh')
        tmux('set-option', '-g', 'detach-on-destroy', 'off')
        tmux('set-window-option', '-g', 'remain-on-exit', 'on')
        tmux('set-environment', '-g', 'PATH', env['PATH'])
        assert tmux('show-options', '-gqv', 'prefix') == 'C-Space'
        assert str(user_config) in tmux('display-message', '-p',
                                       '#{config_files}')
        tmux('source-file', str(user_config))
        master, client = attach('first')
        before = tmux('display-message', '-p', '#{pid}|#{pane_id}')
        tmux('set-option', '-g', 'prefix', 'C-z')
        press(master, b'\x02q')
        wait_for(lambda: tmux('show-options', '-gqv', 'prefix') == 'C-Space',
                 'prefix q reloads the discovered XDG config')
        assert tmux('display-message', '-p', '#{pid}|#{pane_id}') == before
        assert tmux('list-sessions', '-F', '#{session_name}') == 'first'
        print('ok - native XDG discovery and real reload preserve the pane')
        press(master, b'\x02a')
        wait_for(lambda: len(records('launches.jsonl')) == 1,
                 'prefix a launches Pi')
        wait_for(lambda: attached(), 'popup client attaches')
        wait_for(lambda: b'Scout | prefix+a: hide | /new: reset'
                 in terminal_output, 'Scout popup title is rendered')
        launch = records('launches.jsonl')[0]
        agent_pane = tmux('display-message', '-p', '-t', target, '#{pane_id}')
        agent_identity = tmux('display-message', '-p', '-t', target,
                              '#{pid}|#{session_id}|#{pane_id}|#{pane_pid}')
        origin = tmux('show-options', '-qv', '-t', target,
                      '@dotfiles-agent-origin')
        assert f'Pane: {pane}' in origin and str(project) in origin
        assert f'Client: {client}' in origin
        assert launch['cwd'] == str(home.resolve())
        args = launch['args']
        assert args[0:2] == ['--continue', '--session-dir']
        assert '/tmux-agent/' in args[2]
        assert args[3] == '--append-system-prompt'
        assert '@dotfiles-agent-origin' in args[4]
        assert len(args) == 5  # No initial user turn or forced model/trust.
        assert tmux('show-options', '-v', '-t', target, 'status') == 'off'
        assert tmux('show-options', '-v', '-t', target,
                    'detach-on-destroy') == 'on'
        assert tmux('show-options', '-gqv', 'detach-on-destroy') == 'off'

        # A partial line belongs to Pi's terminal, not the popup client.
        press(master, b'unsent draft')
        press(master, b'\x02a')
        wait_for(lambda: not attached(), 'same binding hides popup')
        assert f'{client}|first' in tmux(
            'list-clients', '-F', '#{client_name}|#{session_name}')
        assert tmux('display-message', '-p', '-t', 'first:',
                    '#{pane_id}') == pane
        tmux('set-option', '-g', 'prefix', 'C-z')
        press(master, b'\x02q')
        wait_for(lambda: tmux('show-options', '-gqv', 'prefix') == 'C-Space',
                 'reload completes while concierge is hidden')
        assert tmux('display-message', '-p', '-t', target,
                    '#{pid}|#{session_id}|#{pane_id}|#{pane_pid}') \
            == agent_identity
        assert len(records('launches.jsonl')) == 1
        press(master, b'\x00a')  # Primary Ctrl-Space prefix works too.
        wait_for(lambda: attached(), 'primary prefix reopens popup')
        press(master, b'\r')
        wait_for(lambda: 'unsent draft' in records('inputs.jsonl'),
                 'draft survives hide and reopen')

        press(master, b'work\r\x02a')
        wait_for(lambda: not attached(), 'hide while agent is working')
        wait_for(lambda: 'work' in records('inputs.jsonl'),
                 'work completes while hidden')
        assert len(records('launches.jsonl')) == 1
        print('ok - both prefixes toggle; '
              'process, draft and work survive hiding')

        other_pane = tmux('new-session', '-d', '-P', '-F', '#{pane_id}',
                          '-s', 'second', '-c', str(home), 'sleep', '120')
        tmux('switch-client', '-c', client, '-t', 'second')
        press(master, b'\x02a')
        wait_for(lambda: attached(), 'summon from another session')
        origin = tmux('show-options', '-qv', '-t', target,
                      '@dotfiles-agent-origin')
        assert f'Pane: {other_pane}' in origin and 'Session: second ' in origin
        assert tmux('display-message', '-p', '-t', target,
                    '#{pane_id}') == agent_pane
        assert len(records('launches.jsonl')) == 1
        press(master, b'/new\r')
        wait_for(lambda: '/new' in records('inputs.jsonl'),
                 '/new reaches Pi without interception')
        print('ok - shared across sessions; '
              'fresh origin and /new input forwarding')

        other_master, other_client = attach('first')
        press(other_master, b'\x02a')
        wait_for(lambda: len(attached().splitlines()) == 2,
                 'second outer client opens the same Pi session')
        assert len(records('launches.jsonl')) == 1
        origin = tmux('show-options', '-qv', '-t', target,
                      '@dotfiles-agent-origin')
        assert f'Client: {other_client}' in origin
        press(other_master, b'\x02a')
        wait_for(lambda: len(attached().splitlines()) == 1,
                 'hide detaches only the invoking popup client')
        press(master, b'\x02a')
        wait_for(lambda: not attached(), 'first popup also hides')
        print('ok - multiple clients share one process; latest summon wins')

        # Explicit exit recreates Pi using the same dedicated history, without
        # depending on the host's remain-on-exit setting.
        press(master, b'\x02a')
        wait_for(lambda: attached(), 'reopen before explicit agent exit')
        press(master, b'quit\r')
        wait_for(lambda: target not in tmux(
            'list-sessions', '-F', '#{session_name}').splitlines(),
            'agent exit removes the owned session')
        wait_for(lambda: len(tmux('list-clients').splitlines()) == 2,
                 'agent exit detaches the popup instead of switching sessions')
        press(master, b'\x02a')
        wait_for(lambda: len(records('launches.jsonl')) == 2,
                 'explicit exit can relaunch Pi')
        wait_for(lambda: attached(), 'new popup attaches after exit')
        assert records('launches.jsonl')[1]['args'][2] == args[2]
        press(master, b'\x02a')
        wait_for(lambda: not attached(), 'relaunched popup hides')
        print('ok - explicit exit relaunches '
              'with the same continuation directory')

        # Direct worktree execution must not depend on an installed home link.
        tmux('kill-session', '-t', target)
        helper.unlink()
        direct = subprocess.Popen([
            str(ROOT / 'tmux/dot-config/tmux/agent-popup'),
            socket, client, other_pane,
        ], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        helpers.append(direct)
        wait_for(lambda: len(records('launches.jsonl')) == 3,
                 'direct helper launches without a home link')
        wait_for(lambda: attached(), 'direct helper opens the same popup')
        press(master, b'\x02a')
        wait_for(lambda: not attached(), 'direct helper popup hides')
        _, stderr = direct.communicate(timeout=5)
        assert direct.returncode == 0, stderr
        stow('--restow')
        print('ok - direct helper execution needs no home-directory link')

        # A reserved-name collision must not adopt/modify another session.
        tmux('kill-session', '-t', target)
        collision = tmux('new-session', '-d', '-P', '-F', '#{pane_id}',
                         '-s', 'dotfiles-agent', 'sleep', '120')
        result = subprocess.run([str(helper), socket, client, other_pane],
                                env=env, capture_output=True, text=True,
                                timeout=5)
        assert result.returncode == 1 and 'not ours' in result.stderr
        assert tmux('display-message', '-p', '-t', target,
                    '#{pane_id}') == collision
        assert not tmux('show-options', '-qv', '-t', target,
                        '@dotfiles-agent-popup')
        tmux('kill-session', '-t', target)
        result = subprocess.run([str(helper), socket, client, '%999999'],
                                env=env, capture_output=True, text=True,
                                timeout=5)
        assert result.returncode == 1 and 'origin pane' in result.stderr
        fake.unlink()
        result = subprocess.run([str(helper), socket, client, other_pane],
                                env=env, capture_output=True, text=True,
                                timeout=5)
        assert result.returncode == 1 and 'pi is unavailable' in result.stderr
        assert tmux('list-sessions', '-F', '#{session_name}') == 'first\nsecond'
        # Failure must release the creation lock.
        tmux('wait-for', '-L', 'dotfiles-agent-popup')
        tmux('wait-for', '-U', 'dotfiles-agent-popup')
        assert not (home / 'SHOULD-NOT-EXIST').exists()
        print('ok - collision, stale-origin and missing-Pi '
              'failures preserve state')
    except Exception:
        print('Synthetic terminal output:',
              repr(terminal_output[-4096:].decode(errors='replace')))
        if (home / 'fake-stderr').exists():
            print('Fake stderr:', (home / 'fake-stderr').read_text())
        raise
    finally:
        subprocess.run([str(bin_dir / 'tmux'), '-S', socket, 'kill-server'],
                       env=env, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)
        for process in helpers:
            process.wait(timeout=5)
        for process, master, slave in clients:
            process.wait(timeout=5)
            os.close(slave)
            os.close(master)

    stow('--delete')
    assert not helper.exists() and not helper.is_symlink()
    assert not user_config.exists() and not user_config.is_symlink()
    assert not (home / '.tmux.conf').is_symlink()
    assert unrelated.read_text() == 'machine-owned\n'
    assert (home / 'launches.jsonl').exists()
    print('ok - unstow preserves unrelated config and machine-owned state')
