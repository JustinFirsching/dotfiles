path_prepend() {
    [ -n "${1:-}" ] || return

    case ":${PATH:-}:" in
        *":$1:"*) ;;
        *)
            PATH="${1}${PATH:+:${PATH}}"
            export PATH
            ;;
    esac
}

path_append() {
    [ -n "${1:-}" ] || return

    case ":${PATH:-}:" in
        *":$1:"*) ;;
        *)
            PATH="${PATH:+${PATH}:}${1}"
            export PATH
            ;;
    esac
}
