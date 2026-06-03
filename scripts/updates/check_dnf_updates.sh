#!/bin/bash
set -u

NTFY_FILE="/home/henry/Documents/Repositories/server_scripts/ntfy_location.txt"
ntfy_channel="$(cat "$NTFY_FILE")"

DEVICE_NAME="Be Quiet PC"
DEVICE_EMOJI="⬆️"

case "${1:-}" in

    now)

        UPDATES=$(dnf check-update --quiet | grep -E '^[a-zA-Z0-9]' | wc -l)
        SECURITY_UPDATES=$(dnf updateinfo list --security --quiet | grep -E '^[A-Z]' | wc -l)
        DOWNLOAD_SIZE=$(dnf upgrade --assumeno 2>&1 | sed -nE 's/.*Need to download ([0-9.]+ [A-Za-z]+).*/\1/p')

        notify-send -a "Check PC" -i folder-download-symbolic -t 4000 "Check and Update PC" "$UPDATES updates available totalling $DOWNLOAD_SIZE. $SECURITY_UPDATES are security updates."
        exit 0
        ;;
esac

if [ "$(date +%u)" -ne 6 ]; then
    echo "Not Saturday, exiting early."
    exit 0
fi

UPDATES=$(dnf check-update --quiet | grep -E '^[a-zA-Z0-9]' | wc -l)
SECURITY_UPDATES=$(dnf updateinfo list --security --quiet | grep -E '^[A-Z]' | wc -l)
DOWNLOAD_SIZE=$(dnf upgrade --assumeno 2>&1 | sed -nE 's/.*Need to download ([0-9.]+ [A-Za-z]+).*/\1/p')

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - $UPDATES updates available totalling $DOWNLOAD_SIZE. $SECURITY_UPDATES are security updates." "ntfy.sh/$ntfy_channel"
