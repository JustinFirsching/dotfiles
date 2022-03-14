if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

typeset -A key

bindkey "^A" beginning-of-line                      # Ctrl+A
bindkey "^E" end-of-line                            # Ctrl+E
bindkey "${terminfo[khome]}" beginning-of-line      # Home key
bindkey "${terminfo[kend]}" end-of-line             # End key
bindkey "${terminfo[kdch1]}" delete-char            # Delete Key
bindkey "^[[1;5C" forward-word                      # Ctrl+Right
bindkey "^[[1;5D" backward-word                     # Ctrl+Right
bindkey "^[[3;5~" kill-word                         # Ctrl+Delete
bindkey '^R' history-incremental-search-backward    # Ctrl+R
bindkey "^Bp" proj-widget                           # Ctrl+B p
