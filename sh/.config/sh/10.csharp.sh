if [ -d "${HOME}/.dotnet" ]; then
    export DOTNET_ROOT="${DOTNET_ROOT:-${HOME}/.dotnet}"
fi

if [ -n "${DOTNET_ROOT:-}" ] && [ -d "${DOTNET_ROOT}" ]; then
    case ":$PATH:" in
        *":${DOTNET_ROOT}:"*) ;;
        *) export PATH="${DOTNET_ROOT}:${PATH}" ;;
    esac
fi

if [ -n "${DOTNET_ROOT:-}" ] && [ -d "${DOTNET_ROOT}/tools" ]; then
    case ":$PATH:" in
        *":${DOTNET_ROOT}/tools:"*) ;;
        *) export PATH="${PATH}:${DOTNET_ROOT}/tools" ;;
    esac
fi
