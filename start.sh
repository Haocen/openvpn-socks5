#!/bin/bash

/usr/bin/openvpn.sh &
echo "Setting sockd port to $PORT"
sed -i -e "s/^internal: eth0 port.*$/internal: eth0 port = $PORT/g" /etc/sockd.conf
echo "Setting device to $TUN_DEVICE"
sed -i -e "s/^external: tun0$/external: $TUN_DEVICE/g" /etc/sockd.conf
sleep 15
sockd