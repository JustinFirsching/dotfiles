#!/bin/sh

SCRIPT_DIR=$(dirname -- "$(realpath $0)")
CONFIG=${SCRIPT_DIR%%/}/Packages.config

EXIT_GENERIC=1
EXIT_NO_CONFIG=2

function get_os() {
    local os
    case "$(uname -s)" in
        Darwin) os="macOS" ;;
        Linux|GNU*) os="Linux" ;;
        CYGWIN*|MSYS*|MINGW*) os="Windows" ;;
    esac
    echo $os
    # Return an error if the os never got set
    [ ! -z "$os" ]
}

function get_distro() {
    # Things I care to support:
    #   * Arch Linux
    #   * CentOS
    #   * Debian
    #   * Fedora
    #   * Proxmox
    #   * Ubuntu
    if type -p pveversion >/dev/null; then
        disto="Proxmox VE"
    elif type -p lsb_release >/dev/null; then
        distro=$(lsb_release -si)
    else
        # Source the os-release file
        for file in /etc/lsb-release /usr/lib/os-release \
                    /etc/os-release  /etc/openwrt_release; do
            [ -f "$file" ] && source "$file" && break
        done
        distro="${NAME:-${DISTRIB_ID}}"
    fi
    echo "$distro"
}

function get_package_list() {
    local os=$1
    local distro=$2

    local os_package_key=${os^^}_PACKAGES
    local distro_no_spaces=${distro// }
    local distro_package_key=${distro_no_spaces^^}_PACKAGES

    local package_list="${!os_package_key%% } ${!distro_package_key%% }"

    local group
    for group in $PKG_GROUPS; do
        package_list="$package_list ${!group}"
    done

    local include
    for include in $INCLUDES; do
        package_list="$package_list $include"
    done

    local exclude
    for exclude in $EXCLUDES; do
        package_list="${package_list//$exclude}"
    done

    # Try to trim packages. Shouldn't make a difference if we can't trim them.
    package_list="${package_list%% }"
    if [ "$(which tr sort xargs 2>/dev/null | wc -l)" = "3" ]; then
        package_list=$(tr ' ' '\n' <<< "$package_list" | sort -u | xargs)
    fi

    echo "$package_list"

    # Set the exit code
    [ ! -z "${package_list// }" ]
}

function install_dotfiles() {
    local os=${1:-$(get_os)}
    # If Linux, try to get the distro name
    local distro
    [ "$os" = "Linux" ] && distro=$(get_distro)

    local packages=$(get_package_list "$os" "$distro")
    echo "Installing: $packages"
    stow -t ~ -R $packages
}

function usage() {
    echo "usage: $0 [-h] [-o OS] [-c CONFIG] [PACKAGE OPTIONS]..."
    echo "General Options"
    echo "  -h: Display this help menu"
    echo "  -o OS: Manually set operating system"
    echo "  -c CONFIG: Override package configuration file"
    echo "Package Options"
    echo "  -g GROUP: Include the GROUP package group from the config"
    echo "  -e EXCLUDE: Excludes the EXCLUDE package from stow"
    echo "  -i INCLUDE: Includes the INCLUDE package in stow"
}

while getopts ce:g:hi:o: option; do
    case $option in
        c)
            if [ -f "$OPTARG" ]; then
                CONFIG=$OPTARG
            else
                usage
                >&2 echo "Configuration file not found."
                exit $EXIT_NO_CONFIG
            fi
            ;;
        e) EXCLUDES="${EXCLUDES:+$EXCLUDES }$OPTARG" ;;
        g) PKG_GROUPS="${PKG_GROUPS:+$PKG_GROUPS }$OPTARG" ;;
        h) usage && exit ;;
        i) INCLUDES="${INCLUDES:+$INCLUDES }$OPTARG" ;;
        o) os="$OPTARG" ;;
        *) usage && exit $EXIT_GENERIC ;;
    esac
done

source $CONFIG
install_dotfiles "$os"
