#!/usr/bin/env bash

# curl -fsSL https://bun.sh/install | bash
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    path_prepend "$BUN_INSTALL/bin"
fi

if [ -d "$BUN_INSTALL/_bun" ]; then
    source "$HOME/.bun/_bun"
fi
