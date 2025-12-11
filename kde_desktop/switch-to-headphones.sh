#!/usr/bin/env bash
set -u

# Launch Option: /home/henry/Documents/Repositories/server_scripts/kde_desktop/switch-to-headphones.sh %command%

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
    fi
}

HEADPHONES="alsa_output.usb-Razer_Razer_BlackShark_V2_Pro-00.analog-stereo"
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"

# On game start, go to headphones.
switch_to_sink "$HEADPHONES"

"$@"            # Runs the command passed from Steam
exit_code=$?    # Capture game's exit code

# On game close, switch back to speakers.
switch_to_sink "$SPEAKERS"

exit $exit_code

