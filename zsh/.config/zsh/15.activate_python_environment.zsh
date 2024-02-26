#!/usr/bin/env zsh

function activate_python_env() {
    [ ! -f .venv/bin/activate ] && return

    # If there is a virtual environment
    if [ ! -z "$VIRTUAL_ENV" ]; then
        # and it isn't from this directory
        # (allowing for other virtualenvs in this directory)
        parent_venv=$(dirname -- "$VIRTUAL_ENV")
        if [ "$parent_venv" != "$(pwd)" ]; then
            # Clear it and use this virtual environment
            deactivate
            source .venv/bin/activate
        fi
    # If there isn't a virtual environment
    else
        # Clear it and use this virtual environment
        source .venv/bin/activate
    fi
}

chpwd_functions+=(activate_python_env)
activate_python_env
