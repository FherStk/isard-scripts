#!/bin/bash
ip link set enp1s0 down
ip link set enp2s0 down
ip link set enp3s0 down
ip link set enp4s0 down

ip link set enp1s0 name Default
ip link set enp2s0 name Personal1
ip link set enp3s0 name WireguardVPN
ip link set enp4s0 name GroupNetwork1

ip link set Default up
ip link set Personal1 up
ip link set WireguardVPN up
ip link set GroupNetwork1 up

netplan apply