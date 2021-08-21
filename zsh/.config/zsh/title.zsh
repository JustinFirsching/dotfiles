# Manage Terminal Title
DISABLE_AUTO_TITLE="true"
if [[ -z "$SSH_TTY" ]]; then
    case "$TERM" in
        vte*|xterm*|rxvt*|st*)
            # This will show user@host:DIR when not in a program
            precmd() {
                # print -Pn "\e]%n@%M:%~\a"
                echo  -n -e "\e]%n@%M:%~\a"
            }
            # This will show user@host:DIR - PROG when in a program
            # preexec () { print -Pn "\e]%n@%M:%~ - $1\a" }
            # This will show PROG when in a program
            preexec () {
                # print -Pn "\e]Terminal - $1\a"
                echo -n -e "\e]Terminal - $1\a"
            }
    esac
fi
