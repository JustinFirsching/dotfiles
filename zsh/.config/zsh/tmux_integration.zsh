if [ ! -z "$(which tmux-loop)" ]; then
    TMUX_MAIN="source tmux-loop"
elif [ ! -z "$(which tmux)" ]; then
    TMUX_MAIN="tmux new-session -A -s main"
fi

# Setup TMUX_MAIN as a widget
function __proj() {
    BUFFER="proj" && zle accept-line
}
zle -N proj-widget __proj

# Setup TMUX_MAIN to run at startup
eval $TMUX_MAIN
