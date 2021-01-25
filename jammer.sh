#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "You need to run as root!"
    exit 1
fi

while [ 1 ]; do
    DEVICES=$(hcitool scan | awk 'length NR>2{print $1}')
    for bd_addr in $DEVICES; do
        echo "Pinging ${bd_addr}..."
        sudo l2ping -f $bd_addr > /dev/null 2>/dev/null &
    done
done
