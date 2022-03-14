#!/bin/sh

function __load_settings(){
    local config=$1
    if [ -d "$config" ]; then
        local scripts=$(find $config -type f)

        local src
        for src in $scripts; do
            source $src
        done
    elif [ -f "$config" ]; then
        source $config
    fi
}

__load_settings "$HOME/.config/sh"
source tmux-loop
