if [ ! -z "$(which tmux-loop)" ]; then
    TMUX_MAIN="source tmux-loop"
elif [ ! -z "$(which tmux)" ]; then
    TMUX_MAIN="tmux new-session -A -s main"
fi

# Setup TMUX_MAIN as a widget
function attach-tmux-main() {
    [ ! -z $TMUX_MAIN ] && BUFFER="$TMUX_MAIN" && zle accept-line
}
zle -N attach-tmux-main

# Setup TMUX_MAIN to run at startup
eval $TMUX_MAIN
