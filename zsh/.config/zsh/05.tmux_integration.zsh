function __proj() {
    BUFFER="proj" && zle accept-line
}

zle -N proj-widget __proj
zle -A proj-widget main
