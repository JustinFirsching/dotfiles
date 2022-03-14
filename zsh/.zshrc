# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle :compinstall filename '/home/justin/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100000
setopt autocd extendedglob histignorespace
# End of lines configured by zsh-newuser-install

if [[ -f ~/.zprofile ]]; then
    . ~/.zprofile
fi

function __load_settings(){
    local config="$1"
    if [ -d "$config" ]; then
        local src
        for src in "${config%%/}"/**/*(N-.); do
            . $src
        done
    elif [ -f "$config" ]; then
        . $config
    fi
}
__load_settings "$HOME/.config/zsh"
__load_settings "$HOME/.config/sh"
source tmux-loop
