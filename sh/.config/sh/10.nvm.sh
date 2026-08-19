#!/bin/sh

# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

for __nvm_source_dir in "${NVM_SOURCE_DIR:-}" "/opt/homebrew/opt/nvm" "/usr/local/opt/nvm" "$NVM_DIR"; do
    [ -n "$__nvm_source_dir" ] || continue
    [ -f "$__nvm_source_dir/nvm.sh" ] || continue
    break
done

if [ -n "${__nvm_source_dir:-}" ] && [ -f "$__nvm_source_dir/nvm.sh" ]; then
    . "$__nvm_source_dir/nvm.sh" --no-use

    # Child processes cannot use the lazy shell functions, so give them a real Node.
    __nvm_default_version="$(nvm_version default)"
    __nvm_default_bin="$NVM_DIR/versions/node/$__nvm_default_version/bin"
    if [ -x "$__nvm_default_bin/node" ]; then
        path_prepend "$__nvm_default_bin"
    fi
    unset __nvm_default_version __nvm_default_bin

    __nvm_completion="$__nvm_source_dir/bash_completion"
    if [ ! -f "$__nvm_completion" ]; then
        __nvm_completion="$__nvm_source_dir/etc/bash_completion.d/nvm"
    fi

    if [ -f "$__nvm_completion" ]; then
        . "$__nvm_completion"
    fi
    unset __nvm_completion

    __nvm_lazy_load() {
        unset -f node npm npx corepack yarn pnpm 2>/dev/null || true
        nvm_auto use

        unset -f __nvm_lazy_load 2>/dev/null || true
    }

    node() {
        __nvm_lazy_load && command node "$@"
    }

    npm() {
        __nvm_lazy_load && command npm "$@"
    }

    npx() {
        __nvm_lazy_load && command npx "$@"
    }

    corepack() {
        __nvm_lazy_load && command corepack "$@"
    }

    yarn() {
        __nvm_lazy_load && command yarn "$@"
    }

    pnpm() {
        __nvm_lazy_load && command pnpm "$@"
    }
fi
