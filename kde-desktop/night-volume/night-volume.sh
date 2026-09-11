#!/usr/bin/env bash
set -euo pipefail

# Script runs on startup in the KDE settings.

# Volume settings.
NIGHT_VOLUME=60   # Volume after 21:00.
DAY_VOLUME=80     # Volume before 21:00.

# Speaker name in pactl list short sinks.
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"

# Current output to check if it is speakers.
CURRENT_SINK=$(pactl info | awk -F': ' '/Default Sink:/ {print $2}')

# Only apply if speakers are active.
if [[ "$CURRENT_SINK" == "$SPEAKERS" ]]; then
    HOUR=$(date +%H)
    # If past 21:00
    if (( HOUR >= 21 || HOUR < 8 )); then
        pactl set-sink-volume "$CURRENT_SINK" "${NIGHT_VOLUME}%"
        notify-send -a "Night Volume" -i audio-volume-medium-symbolic -t 4000 "Night Volume" "Volume decreased to $NIGHT_VOLUME%."
    else
        pactl set-sink-volume "$CURRENT_SINK" "${DAY_VOLUME}%"
        notify-send -a "Night Volume" -i audio-volume-high-symbolic -t 4000 "Night Volume" "Volume set to $DAY_VOLUME%."
    fi
fi
