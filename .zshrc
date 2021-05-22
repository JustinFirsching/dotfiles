# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle :compinstall filename '/home/justin/.zshrc'

function zle-line-init () { echoti smkx }
function zle-line-finish () { echoti rmkx }
zle -N zle-line-init
zle -N zle-line-finish

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100000
setopt autocd extendedglob
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
