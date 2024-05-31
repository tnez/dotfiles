function theme -a name -d "Globally change to color theme by name"
    if test -z "$name"
        echo "ERROR: Name is required"
        return 127
    end

    if test -n "$TMUX"
        echo "ERROR: Must be run outside of tmux"
        return 127
    end

    # iTerm2 - (macos only) if $name is equal to 'day' then switch the default
    # profile to 'Light', otherwise switch the default profile to 'Dark'


    # TMUX
    # Loop through all tmux sessions and for each window in each session echo
    # out the window index and window name.
    for session in (tmux list-sessions -F "#{session_name}")
        echo "Session: $session"
    end

    # NeoVim
end

set -l available_color_themes night moon storm day
complete --no-files --command theme --condition "not __fish_seen_subcommand_from $available_color_themes" --arguments "$available_color_themes"
