#!/bin/bash

# Wait for 30 seconds.
# sleep 30

# Find the window ID for "Steam Big Picture Mode".
WINDOW_ID=$(wmctrl -l | grep "Steam Big Picture Mode" | awk '{print $1}')

# Check if the window ID was found.
if [ -n "$WINDOW_ID" ]; then
    # Run the wmctrl command to resize the window.
    echo "Steam's Window ID is $WINDOW_ID."
    wmctrl -i -r "$WINDOW_ID" -e 0,-1,-1,2120,1000
else
    echo "Steam Big Picture Mode is not open."
fi
