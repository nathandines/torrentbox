#!/bin/bash

set -euo pipefail

function usage {
  echo "USAGE: $(basename "$0") <up|down> <route_table_number>" 1>&2
  exit 1
}

case $1 in
  up)     ACTION='add';;
  down)   ACTION='del';;
  *)      usage;;
esac

IFACE_IP="$(ip addr show dev "$IFACE" | grep -m1 -oP '(?<=^    inet )(?:\d{1,3}\.){3}\d{1,3}')"
GATEWAY_IP="$(ip route show table main dev "$IFACE" exact 0.0.0.0/0 | awk '{ print $3 }')"
SUBNET="$(ip route show table main dev "$IFACE" src "$IFACE_IP" | awk '{ print $1 }')"
TABLE=$2

set -x

ip route "$ACTION" "$SUBNET" dev "$IFACE" src "$IFACE_IP" table "$TABLE"
ip route "$ACTION" default via "$GATEWAY_IP" table "$TABLE"
ip rule "$ACTION" from "$IFACE_IP" table "$TABLE"
