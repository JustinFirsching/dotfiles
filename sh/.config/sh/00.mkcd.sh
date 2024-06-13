#!/bin/sh

function mkcd() {
    local dirname=$1
    mkdir -p "$dirname"
    cd "$dirname"
}
