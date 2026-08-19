if [ -d "${HOME}/.dotnet" ]; then
    export DOTNET_ROOT="${DOTNET_ROOT:-${HOME}/.dotnet}"
fi

if [ -n "${DOTNET_ROOT:-}" ] && [ -d "${DOTNET_ROOT}" ]; then
    path_prepend "$DOTNET_ROOT"
fi

if [ -n "${DOTNET_ROOT:-}" ] && [ -d "${DOTNET_ROOT}/tools" ]; then
    path_append "$DOTNET_ROOT/tools"
fi
