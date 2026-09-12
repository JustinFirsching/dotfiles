# Detect GOROOT each time this file is sourced so Go upgrades do not leave a
# stale value from the previous installation.
__previous_goroot=${GOROOT:-}
GOROOT=$(GOROOT= go env GOROOT 2>/dev/null)
GOROOT=${GOROOT:-/usr/local/go}

if [ -n "$__previous_goroot" ] && [ "$__previous_goroot" != "$GOROOT" ]; then
    if [ -d "$GOROOT" ]; then
        path_replace "$__previous_goroot/bin" "$GOROOT/bin"
    else
        path_remove "$__previous_goroot/bin"
    fi
fi

# If we have Go installed and found the GOROOT, add it to PATH along with the
# Go directory in $HOME for tools
if [ -d "$GOROOT" ]; then
    export GOROOT
    path_prepend "$GOROOT/bin"
    path_prepend "$HOME/go/bin"
fi

unset __previous_goroot
