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

_load_settings(){
    _dir="$1"
    if [ -d "$_dir" ]; then
        for config in "$_dir"/**/*(N-.); do
            . $config
        done
    fi
}
_load_settings "$HOME/.config/zsh"
