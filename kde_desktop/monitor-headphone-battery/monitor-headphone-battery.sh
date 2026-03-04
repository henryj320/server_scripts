#!/usr/bin/env bash
set -u

STATE_FILE="/home/henry/Documents/Repositories/server_scripts/kde_desktop/monitor-headphone-battery/currently-using.txt"
MINUTES_FILE="/home/henry/Documents/Repositories/server_scripts/kde_desktop/monitor-headphone-battery/minutes.txt"

HEADPHONES="alsa_output.usb-Razer_Razer_BlackShark_V2_Pro-00.analog-stereo"
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"

# "reset" and "check" options added.
case "${1:-}" in

    reset)
        echo "0" > "$MINUTES_FILE"
        exit 0
        ;;

    check)
        minutes="$(cat "$MINUTES_FILE")"
        hours=$((minutes / 60))
        remainder=$((minutes % 60))

        # curl -d "🎧 Razer Headphones - In use for ${hours}h ${remainder}m" "https://ntfy.sh/whale_server_1"
        notify-send -a "Headphone Monitor" -i audio-headphones-symbolic "Razer Headphones" "In use for ${hours} hours ${remainder} minutes"

        exit 0
        ;;

    "")
        ;;
esac


# Get current device.
current="$(pactl info | awk -F': ' '/Default Sink:/ {print $2}')"

# Get the device 5 minutes ago.
previous_state="$(cat "$STATE_FILE")"

# If device is headphones.
if [[ "$current" == "$HEADPHONES" ]]; then

    # If previously using speakers...
    if [[ "$previous_state" != "HEADPHONES" ]]; then
        echo "HEADPHONES" > "$STATE_FILE"
        exit 0
    fi

    # If previously still using headphones...
    minutes="$(cat "$MINUTES_FILE")"
    minutes=$((minutes + 5))
    echo "$minutes" > "$MINUTES_FILE"

    # Ntfy every hour of usage.
    if (( minutes > 0 && minutes % 60 == 0 )); then
        hours=$((minutes / 60))
        curl -d "🎧 Razer Headphones - In use for ${hours} hours" "https://ntfy.sh/whale_server_1"
    fi

    exit 0
fi

# If device is speakers.
if [[ "$previous_state" != "SPEAKERS" ]]; then
    echo "SPEAKERS" > "$STATE_FILE"
fi
