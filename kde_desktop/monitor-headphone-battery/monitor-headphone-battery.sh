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

        TOTAL=1360
        remaining=$((TOTAL - minutes))

        if (( remaining < 0 )); then
            remaining=0
        fi

        percent=$((remaining * 100 / TOTAL))

        hours=$((remaining / 60))
        remainder=$((remaining % 60))

        # Round percentage down to nearest 10 for icon name
        icon_level=$(( (percent / 10) * 10 ))
        icon="battery-level-${icon_level}-symbolic"

        notify-send -a "Headphone Monitor" -i "$icon" "Razer Headphones" "${percent}% battery remaining (${hours} hours ${remainder} minutes)"

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

    # Notify at battery thresholds.
    case "$minutes" in
        680)
            notify-send -a "Headphone Monitor" -i battery-level-50-symbolic "Razer Headphones" "50% battery remaining"
            ;;
        1020)
            notify-send -a "Headphone Monitor" -i battery-level-20-symbolic "Razer Headphones" "25% battery remaining (6 hours)"
            ;;
        1225)
            notify-send -a "Headphone Monitor" -i battery-level-10-symbolic "Razer Headphones" "10% battery remaining (2 hours)"
            ;;
        1290)
            notify-send -a "Headphone Monitor" -i battery-level-10-symbolic "Razer Headphones" "5% battery remaining (1 hour)"
            ;;
        1330)
            notify-send -a "Headphone Monitor" -i battery-level-10-symbolic "Razer Headphones" "2% battery remaining (30 minutes)"
            ;;
    esac

    exit 0
fi

# If device is speakers.
if [[ "$previous_state" != "SPEAKERS" ]]; then
    echo "SPEAKERS" > "$STATE_FILE"
fi
