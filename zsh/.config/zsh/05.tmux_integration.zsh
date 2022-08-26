# Setup TMUX_MAIN as a widget
function __proj() {
    BUFFER="proj" && zle accept-line
}
zle -N proj-widget __proj
