#!/bin/bash

set -euo pipefail

#exec 1> >(logger -s -t "$(basename "$0")") 2>&1

function usage() {
    echo "Usage: $0 [-a <address>] [-c <ping count>] [-f <counter file>] -i <interface>" >&2
    exit 1
}

function die() {
    echo "$2" >&2
    exit "$1"
}

function restart_network() {
    ifdown --force "$1"
    ifup "$1"
}

address=1.1.1.1
count=10
counterfile=/tmp/network_restarter.cnt

while getopts ":a:c:f:i:" opt; do
    case "${opt}" in
        a)
            address=${OPTARG}
            ;;
        c)
            count=${OPTARG}
            ;;
        f)
            counterfile=${OPTARG}
            ;;
        i)
            interface=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

[[ ! -v interface ]] && die 3 "Interface (-i) must be provided"

if [[ ! -e "$counterfile" ]]; then
    echo 0 >"$counterfile" || die 2 "Unable to create counter file $counterfile"
fi

failed_attempts=$(<"$counterfile")

if ping -c 1 "$address" >/dev/null 2>&1; then
    if [[ "$failed_attempts" -gt 0 ]]; then
        echo "Network is back, resetting counter"
    fi
    echo 0 >"$counterfile"
    exit 0
else
    failed_attempts=$((failed_attempts+1))
    echo "Unable to reach $address, attempt $failed_attempts of $count"
    echo "$failed_attempts" >"$counterfile"
    if [[ "$failed_attempts" -ge "$count" ]]; then
        echo "Restarting network (failed_attempts=$failed_attempts)"
        restart_network "$interface"
        echo "Resetting counter"
        echo 0 >"$counterfile"
    fi
fi
