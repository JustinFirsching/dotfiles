#!/usr/bin/env bash

# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
if [ -d "$HOME/.nvm" ]; then
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    source $NVM_DIR/nvm.sh
    source $NVM_DIR/bash_completion
fi
