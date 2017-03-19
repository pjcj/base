#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

usage() {
    echo <<EOT
$0 --help
EOT
    exit 0
}
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
_p() { echo "$*" | tee -a "$LOG_FILE" >&2; }
pt() { _p "[TRACE]   $*";                  }
pd() { _p "[DEBUG]   $*";                  }
pi() { _p "[INFO]    $*";                  }
pw() { _p "[WARNING] $*";                  }
pe() { _p "[ERROR]   $*";                  }
pf() { _p "[FATAL]   $*"; exit 1;          }

cleanup() {
    pt "Cleaning up"
    # Remove temporary files
    # Restart services
    # ...
}

main() {
    pt "Starting"
    # implementation
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    main
fi
