#!/bin/bash
set -euo pipefail
# set -x
# IFS=$'\n\t'

usage() {
    echo <<EOT
$0 --help
EOT
    exit 0
}
verbose=0
expr "$*" : ".*--help"    > /dev/null && usage
expr "$*" : ".*--verbose" > /dev/null && verbose=1

readonly LOG_FILE="/tmp/$(basename "$0").log"
_p() { echo "$*" | tee -a "$LOG_FILE" >&2; }
pt() { _p "[TRACE]   $*";                  }
pd() { _p "[DEBUG]   $*";                  }
pi() { _p "[INFO]    $*";                  }
pw() { _p "[WARNING] $*";                  }
pe() { _p "[ERROR]   $*";                  }
pf() { _p "[FATAL]   $*"; exit 1;          }

cleanup() {
    ((verbose)) && pi "Cleaning up"
    # Remove temporary files
    # Restart services
    # ...
}

main() {
    ((verbose)) && pi "Running $*"
    # implementation
    case "$1" in
        options)
            perl -nE 'say $1 =~ s/"//gr =~ s/\s*\|\s*/\n/gr if /^ {8}"?([a-zA-Z0-9_ "|\\]+)"?(?:\)|\s*\|\s*\\)$/ && $1 !~ /^_/' < "$0"
            ;;
        *)
            echo Unknown option "$1"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    main "$@"
fi

# For zsh completion:
# _%FILE%() { reply=($(%FILE% options)) }
# compctl -K _%FILE% %FILE%
