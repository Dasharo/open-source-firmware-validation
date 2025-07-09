#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 3mdeb <contact@3mdeb.com>
#
# SPDX-License-Identifier: Apache-2.0

INTERFACE=$1
DEL=$2
BR_NAME=br0

function print_help {
    echo ""
    echo "Usage: $0 <interface> [del]"
    echo ""
    echo "The script creates a bridged interface that will be connected"
    echo "to a network of given <interface>. The given interface is"
    echo "toggled down."
    echo ""
    echo "Use optional [del] option to delete the bridge and restore"
    echo "the original interface"
    echo ""
    echo "Examples:"
    echo "  Set up bridge interface:"
    echo "    $0 enp0s1"
    echo "  Remove bridge and restore original interface:"
    echo "    $0 enp0s1 del"
}

if [[ -z $INTERFACE ]]; then
    print_help
    exit 1
fi

ip link show $INTERFACE &> /dev/null
if [[ $? -ne 0 ]]; then
    print_help
    exit 1
fi

if [[ $DEL == "del" ]]; then
    ip link show $BR_NAME &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Bridge interface $BR_NAME does not exist"
        exit 0
    fi

    BR_IP=$(ip addr show $BR_NAME | awk '/inet / {print $2}')

    echo "Deleting $BR_NAME IP: $BR_IP on $INTERFACE"

    ip link del $BR_NAME
    ip link set $INTERFACE up
else
    ip link show $BR_NAME &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Bridge interface $BR_NAME already exists"
        exit 0
    fi
    BR_IP=$(ip addr show $INTERFACE | awk '/inet / {print $2}')

    echo "Setting up interface $BR_NAME IP: $BR_IP on $INTERFACE"

    ip link add name $BR_NAME type bridge
    ip link set $INTERFACE master $BR_NAME
    ip addr flush dev $INTERFACE
    ip link set $BR_NAME up
    ip addr add $BR_IP dev $BR_NAME
fi
