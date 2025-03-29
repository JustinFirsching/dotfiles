# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100000
setopt autocd extendedglob appendhistory histignorespace histreduceblanks incappendhistory
# End of lines configured by zsh-newuser-install

if [[ -f ~/.zprofile ]]; then
    . ~/.zprofile
fi

function __load_settings(){
    local config="$1"
    if [ -d "$config" ]; then
        local src
        for src in "${config%%/}"/**/*(N-.); do
            bn=$(basename -- "$src")
            # Don't load README files
            [ "${bn%.*}" != "README" ] && . $src
        done
    elif [ -f "$config" ]; then
        bn=$(basename -- "$config")
        # Don't load README files
        [ "${bn%.*}" != "README" ] && . $config
    fi
}
__load_settings "$HOME/.config/sh"
__load_settings "$HOME/.config/zsh"
source tmux-loop
