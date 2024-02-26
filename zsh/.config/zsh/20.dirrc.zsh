#!/usr/bin/env zsh

function source_dirrc() {
    if [[ -f ".dirrc" ]]; then
        source .dirrc
    fi
}

chpwd_functions+=(source_dirrc)
source_dirrc
