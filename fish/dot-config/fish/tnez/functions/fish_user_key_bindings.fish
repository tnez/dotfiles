function fish_user_key_bindings
    fish_vi_key_bindings

    bind -M insert -m default kj backward-char force-repaint

    for mode in insert default visual
        bind -M $mode \cf forward-char
    end

    # Ctrl+T: sesh session picker (outside tmux, C-t is intercepted by tmux inside)
    for mode in insert default
        bind -M $mode \ct 'tv sesh; commandline -f repaint'
    end
end
