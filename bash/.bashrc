#!/bin/bash

function __load_settings(){
    local config=$1
    if [ -d "$config" ]; then
        local scripts=$(find -L $config -type f)

        local src
        for src in $scripts; do
            source $src
        done
    elif [ -f "$config" ]; then
        source $config
    fi
}

__load_settings "$HOME/.config/sh"
__load_settings "$HOME/.config/bash"
source tmux-loop
