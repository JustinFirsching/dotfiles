alias ls='ls --color=auto'
alias sl='ls --color=auto'
alias grep='grep --color=auto'


# If we have xclip installed, set up copy and paste aliases
if command -v xclip &> /dev/null; then
    alias copy='xclip -i -sel clip'
    alias paste='xclip -o -sel clip'
fi

# If we have pbcopy and pbpaste (macOS) installed, set up copy and paste aliases
if command -v pbcopy &> /dev/null && command -v pbpaste &> /dev/null; then
    alias copy='pbcopy'
    alias paste='pbpaste'
fi
