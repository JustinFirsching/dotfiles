#!/usr/bin/env zsh

function source_dotenv() {
    if [[ -f ".dotenv" ]]; then
        source .dotenv
    fi
}

chpwd_functions+=(source_dotenv)
source_dotenv
