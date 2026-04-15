#!/bin/bash

NTFY_FILE="/home/henry/Documents/Repositories/server_scripts/ntfy_location.txt"
ntfy_channel="$(cat "$NTFY_FILE")"

DEVICE_NAME="Be Quiet PC"
DEVICE_EMOJI="🖥️"

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Device turned off." "ntfy.sh/$ntfy_channel"
