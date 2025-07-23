function gdiff -d "Open comprehensive git diff viewer in neovim against origin/main"
    set -l dry_run false

    # Parse arguments
    for arg in $argv
        switch $arg
            case --dry-run -n
                set dry_run true
            case --help -h
                echo "Usage: gdiff [--dry-run|-n] [--help|-h]"
                echo ""
                echo "Open comprehensive git diff viewer showing working tree + staged + committed changes vs origin/main"
                echo ""
                echo "Options:"
                echo "  --dry-run, -n  Show what would be executed without opening neovim"
                echo "  --help, -h     Show this help message"
                return 0
        end
    end

    # Ensure we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Check if origin/main exists, fallback to main, then master
    set -l base_branch
    if git rev-parse --verify origin/main >/dev/null 2>&1
        set base_branch origin/main
    else if git rev-parse --verify main >/dev/null 2>&1
        set base_branch main
    else if git rev-parse --verify master >/dev/null 2>&1
        set base_branch master
    else
        echo "Error: Could not find base branch (origin/main, main, or master)"
        return 1
    end

    set -l nvim_cmd "NVIM_APPNAME=lazyvim nvim -c 'DiffviewOpen $base_branch'"

    echo "Opening diff view: working tree + staged + commits vs $base_branch"

    if test $dry_run = true
        echo "Would execute: $nvim_cmd"
        return 0
    end

    # Open neovim with diffview showing comprehensive diff vs base branch
    eval $nvim_cmd
end

