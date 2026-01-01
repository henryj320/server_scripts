#!/bin/bash

DEVICE_NAME="Be Quiet PC"
DEVICE_EMOJI="🖥️"

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Device powered up." "ntfy.sh/whale_server_1"
