#!/bin/bash
set -euo pipefail
# set -x
# IFS=$'\n\t'

script=$(basename "$0")
dir=$(readlink -f "$(dirname "$0")/../..")
readonly LOG_FILE="/tmp/$script.log"
_p() { l=$1; shift; echo "$l: $script $*" | tee -a "$LOG_FILE" >&2; }
pt() { _p "[TRACE]  " "$*";                                         }
pd() { _p "[DEBUG]  " "$*";                                         }
pi() { _p "[INFO]   " "$*";                                         }
pw() { _p "[WARNING]" "$*";                                         }
pe() { _p "[ERROR]  " "$*";                                         }
pf() { _p "[FATAL]  " "$*"; exit 1;                                 }

usage() {
    cat <<EOT
$script --help
$script --verbose
$script options
EOT
    exit 0
}

verbose=0
expr "$*" : ".*--help"    > /dev/null && usage
expr "$*" : ".*--verbose" > /dev/null && verbose=1

cleanup() {
    declare -r res=$?
    ((verbose)) && pi "Cleaning up"
    exit $res
}


cleanup() {
    declare -r res=$?
    ((verbose)) && pi "Cleaning up"
    exit $res
}

main() {
    ((verbose)) && pi "Running $*"
    [ -z "${1:-}" ] && pf "Missing argument"
    case "$1" in
        # implementation
        options)
            perl -nE 'say $1 =~ s/"//gr =~ s/\s*\|\s*/\n/gr if /^ {8}"?([a-zA-Z0-9_ "|\\]+)"?(?:\)|\s*\|\s*\\)$/ && $1 !~ /^_/' < "$0"
            ;;
        *)
            pf "Unknown option: $1"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT INT
    main "$@"
fi

# For zsh completion:
# _%FILE%() { reply=($(%FILE% options)) }
# compctl -K _%FILE% %FILE%
