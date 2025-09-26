#!/bin/sh

if [ -f /opt/homebrew/bin/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d /opt/homebrew/opt/findutils ]; then
    export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
fi

if [ -d /opt/homebrew/opt/coreutils ]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi

if [ -d /opt/homebrew/opt/python/libexec/bin ]; then
    export PATH="/opt/homebrew/opt/python/libexec/bin:$PATH"
fi
