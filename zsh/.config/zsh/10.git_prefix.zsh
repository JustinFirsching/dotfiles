#!/usr/bin/env zsh

# Enabling and setting git info var to be used in prompt config.
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
# This line obtains information from the vcs.
zstyle ':vcs_info:git*' formats " (%b)"

function update_vcs_info() {
    local is_bare
    is_bare=$(git rev-parse --is-bare-repository 2>/dev/null)

    if [[ "$is_bare" == true ]]; then
        vcs_info_msg_0_=''
    else
        vcs_info
    fi
}

precmd_functions+=(update_vcs_info)

# Enable substitution in the prompt.
setopt prompt_subst

# Config for the prompt. PS1 synonym.
export PS1='%n@%m:%c${vcs_info_msg_0_}$ '
