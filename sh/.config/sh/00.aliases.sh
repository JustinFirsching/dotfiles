alias ls='ls --color=auto'
alias sl='ls --color=auto'
alias grep='grep --color=auto'


# Cross-platform clipboard aliases that work on Linux, macOS, and in tmux
_setup_clipboard() {
    # Detect if we're in tmux
    if [ -n "$TMUX" ]; then
        # In tmux, use tmux's clipboard commands which will use the correct backend
        alias copy='tmux load-buffer -'
        alias paste='tmux save-buffer -'
    # macOS (check for Darwin kernel)
    elif [ "$(uname -s)" = "Darwin" ]; then
        if command -v pbcopy &> /dev/null && command -v pbpaste &> /dev/null; then
            alias copy='pbcopy'
            alias paste='pbpaste'
        fi
    # Linux
    else
        # Try xclip first (most common)
        if command -v xclip &> /dev/null; then
            alias copy='xclip -i -sel clip'
            alias paste='xclip -o -sel clip'
        # Fallback to xsel if available
        elif command -v xsel &> /dev/null; then
            alias copy='xsel --clipboard --input'
            alias paste='xsel --clipboard --output'
        # Wayland: try wl-copy/wl-paste
        elif command -v wl-copy &> /dev/null && command -v wl-paste &> /dev/null; then
            alias copy='wl-copy'
            alias paste='wl-paste'
        fi
    fi
}

_setup_clipboard
