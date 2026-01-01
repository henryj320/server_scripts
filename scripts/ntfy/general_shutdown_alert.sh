#!/bin/bash

DEVICE_NAME="Be Quiet PC"
DEVICE_EMOJI="🖥️"

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Device turned off." "ntfy.sh/whale_server_1"
