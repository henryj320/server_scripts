#!/bin/bash

NTFY_FILE="/home/software/repositories/server_scripts/ntfy_location.txt"
ntfy_channel="$(cat "$NTFY_FILE")"

DEVICE_NAME="Whale Server"
DEVICE_EMOJI="⬆️"

UPDATES=$(apt list --upgradeable 2>/dev/null | grep -v "^Listing" | wc -l)
SECURITY_UPDATES=$(apt list --upgradeable 2>/dev/null | grep -i security | wc -l)

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - $UPDATES updates available. $SECURITY_UPDATES are security updates." "ntfy.sh/$ntfy_channel"
