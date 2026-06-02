alias ls='ls --color=auto'
alias sl='ls --color=auto'
alias grep='grep --color=auto'


# Cross-platform clipboard aliases that work on Linux, macOS, and in tmux
_setup_clipboard() {
    # Detect if we're in tmux
    if [ -n "$TMUX" ]; then
        # In WSL + tmux, go directly to the Windows clipboard
        if grep -qi microsoft /proc/version 2>/dev/null && command -v clip.exe &> /dev/null && command -v powershell.exe &> /dev/null; then
            alias copy='clip.exe'
            alias paste='powershell.exe -NoProfile -Command Get-Clipboard'
        # In macOS + tmux, use the system clipboard
        elif [ "$(uname -s)" = "Darwin" ] && command -v pbcopy &> /dev/null && command -v pbpaste &> /dev/null; then
            alias copy='pbcopy'
            alias paste='pbpaste'
        else
            alias copy='tmux load-buffer -'
            alias paste='tmux save-buffer -'
        fi
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
