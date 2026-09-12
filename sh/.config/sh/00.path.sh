path_prepend() {
    [ -n "${1:-}" ] || return

    case ":${PATH:-}:" in
        *":$1:"*) path_remove "$1" ;;
    esac

    PATH="${1}${PATH:+:${PATH}}"
    export PATH
}

path_append() {
    [ -n "${1:-}" ] || return

    case ":${PATH:-}:" in
        *":$1:"*) path_remove "$1" ;;
    esac

    PATH="${PATH:+${PATH}:}${1}"
    export PATH
}

path_remove() {
    [ -n "${1:-}" ] || return

    __path=":${PATH:-}:"
    while case "$__path" in *":$1:"*) true ;; *) false ;; esac; do
        __path=${__path%%":$1:"*}:${__path#*":$1:"}
    done

    __path=${__path#:}
    PATH=${__path%:}
    export PATH
    unset __path
}

path_replace() {
    [ -n "${1:-}" ] && [ -n "${2:-}" ] || return
    [ "$1" != "$2" ] || return

    __path=":${PATH:-}:"
    while case "$__path" in *":$1:"*) true ;; *) false ;; esac; do
        __path=${__path%%":$1:"*}:$2:${__path#*":$1:"}
    done

    __path=${__path#:}
    PATH=${__path%:}
    export PATH
    unset __path
}
