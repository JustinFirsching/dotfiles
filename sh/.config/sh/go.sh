# Attempt to detect GOROOT, or fallback to default install location
if [ -z "$GOROOT" ]; then
    GOROOT=$(GOROOT= go env GOROOT 2>/dev/null)
    GOROOT=${GOROOT:-/usr/local/go}
fi

# If we have Go installed and found the GOROOT, add it to PATH along with the
# Go directory in $HOME for tools
if [ -d "$GOROOT" ]; then
    export GOROOT
    export PATH=$HOME/go/bin:$GOROOT/bin:$PATH
fi
