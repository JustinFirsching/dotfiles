export EDITOR=nvim
export TERMINAL=st
export BROWSER=brave
export SHELL="$(command -v zsh)"

export PS1="%n@%M:%c$ "

export GPG_TTY=$TTY

path_prepend "$HOME/.local/bin"

export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/default-runtime}
