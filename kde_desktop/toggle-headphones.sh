#!/usr/bin/env bash
set -u

# Switch output (sink) to/from headphones.
switch_to_sink() {
    local target="$1"
    local current
    current="$(pactl info | awk -F': ' '/Default Sink:/ {print $2}')"
    if [[ "$current" == "$HEADPHONES" ]]; then
        echo "Switching to: $SPEAKERS (speakers)"
        pactl set-default-sink "$SPEAKERS"
        # Move existing streams
        pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
            pactl move-sink-input "$input" "$SPEAKERS"
        done
    elif [[ "$current" == "$SPEAKERS" ]]; then
        echo "Switching to: $HEADPHONES (headphones)"
        pactl set-default-sink "$HEADPHONES"
        # Move existing streams
        pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
            pactl move-sink-input "$input" "$HEADPHONES"
        done
    fi
}

HEADPHONES="alsa_output.usb-Razer_Razer_BlackShark_V2_Pro-00.analog-stereo"
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"

# On game start, go to headphones.
switch_to_sink "$HEADPHONES"
