# Use vim keybinds
bindkey -v

bindkey "" beginning-of-line                      # Ctrl+A
bindkey "" end-of-line                            # Ctrl+E
bindkey "^[[H" beginning-of-line                    # Home key
bindkey "^[[F" end-of-line                          # End key
bindkey "\e[3~" delete-char                         # Delete Key
bindkey "^[[1;5C" forward-word                      # Ctrl+Right
bindkey "^[[1;5D" backward-word                     # Ctrl+Right
bindkey "^[[3;5~" kill-word                         # Ctrl+Delete
bindkey "^[[3;5~" kill-word                         # Ctrl+Delete
bindkey "" backward-kill-word                     # Ctrl+Backspace
bindkey '^R' history-incremental-search-backward    # Ctrl+R


# Remove all Escape commands
bindkey -rM viins '^['

# Use this when I get used to Escape commands to avoid reaching for Escape
# bindkey "^F" vi-cmd-mode
