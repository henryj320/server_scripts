#!/usr/bin/env bash
set -u

# Device names found with:
# pactl list short sources
# pactl list short sinks
HEADPHONES="alsa_output.usb-Razer_Razer_BlackShark_V2_Pro-00.analog-stereo"
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"

# Switch output (sink) to/from headphones.
switch_to_sink() {
    local target="$1"
    local current
    current="$(pactl info | awk -F': ' '/Default Sink:/ {print $2}')"
    if [[ "$current" != "$target" ]]; then
        echo "Switching to: $target"
        pactl set-default-sink "$target"
        # Move existing streams
        pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
            pactl move-sink-input "$input" "$target"
        done
        # command -v notify-send >/dev/null && notify-send "Audio switched" "$target"
    fi
}

prev=""

# Check if Vesktop is running and in a call.
while true; do
    if pactl list source-outputs | grep -q 'application.process.binary = "vesktop"'; then
        state="DISCORD_ACTIVE"
    else
        state="DISCORD_IDLE"
    fi

    if [[ "$state" == "DISCORD_ACTIVE" && "$prev" != "DISCORD_ACTIVE" ]]; then
        switch_to_sink "$HEADPHONES"
        prev="$state"
    elif [[ "$state" == "DISCORD_IDLE" && "$prev" != "DISCORD_IDLE" ]]; then
        switch_to_sink "$SPEAKERS"
        prev="$state"
    fi

    sleep 2
done
