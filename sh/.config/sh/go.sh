export GOROOT=$(GOROOT= go env GOROOT 2>/dev/null)

[ ! -z "$GOROOT" ] && export PATH=$GOROOT/bin:$PATH
export PATH=$HOME/go/bin:$PATH
