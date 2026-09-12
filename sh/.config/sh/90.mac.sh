#!/bin/sh

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d /opt/homebrew/bin ]; then
    path_prepend "/opt/homebrew/bin"
fi

if [ -d /opt/homebrew/sbin ]; then
    path_prepend "/opt/homebrew/sbin"
fi

# GNU Bins
for __gnubin in /opt/homebrew/opt/*/libexec/gnubin; do
    if [ -d "$__gnubin" ]; then
        path_prepend "$__gnubin"
    fi
done
unset __gnubin

if [ -d /opt/homebrew/opt/python/libexec/bin ]; then
    path_prepend "/opt/homebrew/opt/python/libexec/bin"
fi
