#!/bin/bash
set -euo pipefail

script=$(basename "$0")
scrdir=$(readlink -f "$(dirname "$0")")
readonly LOG_FILE="/tmp/$script.log"
_p() { l=$1; shift; echo "$l $script: $*" | tee -a "$LOG_FILE" >&2; }
pt() { _p "[TRACE]  " "$*";                                         }
pd() { _p "[DEBUG]  " "$*";                                         }
pi() { _p "[INFO]   " "$*";                                         }
pw() { _p "[WARNING]" "$*";                                         }
pe() { _p "[ERROR]  " "$*";                                         }
pf() { _p "[FATAL]  " "$*"; exit 1;                                 }

usage() {
    cat <<EOT
$script --help
$script --trace --verbose
$script options
EOT
    exit 0
}

cleanup() {
    declare -r res=$?
    ((verbose)) && pi "Cleaning up"
    exit $res
}

PATH="$scrdir:$PATH"
verbose=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            shift
            ;;
        -t|--trace)
            set -x
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        # -d|--driver)
            # driver="$2"
            # shift 2
            # ;;
        *)
            break
            ;;
    esac
done

main() {
    ((verbose)) && pi "Running $*"
    [ -z "${1:-}" ] && pf "Missing argument"
    case "$1" in
        # implementation
        options)
            perl -nE 'say $1 =~ s/"//gr =~ s/\s*\|\s*/\n/gr if /^ {8}"?([a-zA-Z0-9_ "|\\-]+)"?(?:\)|\s*\|\s*\\)$/ && $1 !~ /^_/' < "$0"
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
