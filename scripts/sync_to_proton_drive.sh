#!/bin/bash

# Set variables.
LOCAL_BASE="/home/casa/locations/documents"
REMOTE_NAME="ProtonDrive"

start_timer=$SECONDS

# --- Function to sync a folder with timeout ---
sync_folder() {
    local folder_name="$1"
    local src="$LOCAL_BASE/$folder_name"
    local dst="$REMOTE_NAME:Sync/$folder_name"

    echo -n "Syncing '$folder_name' folder... "

    start_time=$SECONDS
    rclone copy "$src" "$dst" --protondrive-replace-existing-draft=true
    duration=$(( SECONDS - start_time ))
    echo "✅ ($duration seconds)"
}

# --- Check connection to Proton Drive and output used space ---
echo ""
echo -n "Connecting to Proton Drive... "
if ! used_raw=$(rclone about "$REMOTE_NAME:" 2>/dev/null | grep "Used:"); then
    echo "Could not connect to $REMOTE_NAME!"
    exit 1
fi

# Parse to GiB.
used_value=$(echo "$used_raw" | awk '{print $2}')
used_gib=$(printf "%.0f" "$(echo "$used_value" | awk '{print ($1 == int($1)) ? $1 : int($1)+1}')")

echo "✅"
echo "Used space: ${used_gib} GiB"

echo -n "Checking used Proton Drive space... "
if [ "$used_gib" -ge 14 ]; then
    echo "${used_gib} GiB out of 16 GiB. Aborting!"
    curl -d "☁️ Whale Server - Proton Drive sync aborted! Proton Drive nearly full (${used_gib} GiB used)" "ntfy.sh/whale_server_1"
    exit 1
else
    echo "${used_gib} GiB out of 16 GiB ✅"
fi

echo ""

# --- Check all locations to sync exist ---
echo -n "Checking local folders exist... "
folders=("Sandbox" "Travel" "Housing")
for folder in "${folders[@]}"; do
    full_path="$LOCAL_BASE/$folder"
    if [ ! -d "$full_path" ]; then
        echo "Missing: $full_path. Please check before syncing."
        exit 1
    fi
done
echo "✅"
echo ""

# --- Sync each folder ---
sync_folder "Sandbox"
sync_folder "Travel"
sync_folder "Housing"

echo ""

# TODO: Sync Log Files.

# Send Ntfy on Completion.
total_time=$(( SECONDS - start_timer ))
minutes=$(( total_time / 60 ))
seconds=$(( total_time % 60 ))
curl -d "☁️ Whale Server - Proton Drive Sync completed with ${used_gib} GiB stored. Took ${minutes} minutes ${seconds} seconds" "ntfy.sh/whale_server_1"
