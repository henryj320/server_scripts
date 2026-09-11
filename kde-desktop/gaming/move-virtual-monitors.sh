#!/usr/bin/env bash
set -u

# Launch Option: /home/henry/Documents/Repositories/server_scripts/kde_desktop/gaming/move-virtual-monitors.sh %command%
# https://gitlab.gnome.org/GNOME/mutter/-/blob/main/doc/man/gdctl.rst

# Check that the monitors are as expected.
if gdctl show | grep -q 'AW3423DWF' && gdctl show | grep -q 'Q27G2WG4'; then
    echo "Both monitors are connected"
else
    echo "Expected monitors not detected. Exiting."
    exit 1
fi

# Move monitors to diagonally.
gdctl set --logical-monitor --primary --monitor DP-2 --x 2560 --y 0 --logical-monitor --monitor HDMI-1 --x 0 --y 1415

notify-send -a "Monitor Move" -i video-display-symbolic -t 4000 "Monitor Move" "Moved monitors to FPS mode."

# Runs the command passed from Steam.
"$@"

# Capture game's exit code.
exit_code=$?

# On game close, move monitors back.
gdctl set --logical-monitor --monitor HDMI-1 --x 0 --y 0 --logical-monitor --primary --monitor DP-2 --x 2560 --y 0

notify-send -a "Monitor Move" -i video-display-symbolic -t 4000 "Monitor Move" "Monitors returned to original position."


exit $exit_code

