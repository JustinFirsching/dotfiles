if [ -d "$HOME/.nvm" ]; then
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    source $NVM_DIR/nvm.sh
    source $NVM_DIR/bash_completion
fi
