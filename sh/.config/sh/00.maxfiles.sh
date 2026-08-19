#!/bin/sh

__maxfiles_limit=65536

__current_maxfiles=$(ulimit -S -n 2>/dev/null)

if [ -n "$__current_maxfiles" ] && [ "$__current_maxfiles" -lt "$__maxfiles_limit" ] 2>/dev/null; then
    ulimit -S -n "$__maxfiles_limit" 2>/dev/null || true
fi

unset __current_maxfiles __maxfiles_limit
