#!/bin/bash

SCAN_PATH="/home/casa/locations/documents"
LOG_FILE="/home/casa/locations/logs/ClamAV/removed_files.log"

NTFY_TOPIC="https://ntfy.sh/whale_server_1"

DEVICE_EMOJI="🛡️"
DEVICE_NAME="Whale Server"

CLAMDSCAN_BIN="/usr/bin/clamdscan"
DATE_BIN="/usr/bin/date"
ECHO_BIN="/usr/bin/echo"
CURL_BIN="/usr/bin/curl"

# Exclusions.
EXCLUDE_DIRS=("Education" "Housing")

# Log header.
$ECHO_BIN -e "\n\n\n" >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started." >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started."

# Run scan (directory-by-directory).
for dir in "$SCAN_PATH"/*; do
  [ -d "$dir" ] || continue

  BASENAME_DIR="$(basename "$dir")"

  # Skip excluded directories.
  if [[ " ${EXCLUDE_DIRS[@]} " =~ " $BASENAME_DIR " ]]; then
    echo "$($DATE_BIN) - Skipping $dir" >> "$LOG_FILE"
    echo "$($DATE_BIN) - Skipping $dir"
    continue
  fi

  echo "$($DATE_BIN) - Scanning $dir" >> "$LOG_FILE"
  echo "$($DATE_BIN) - Scanning $dir"

  $CLAMDSCAN_BIN \
    --verbose \
    --remove \
    --infected \
    --log="$LOG_FILE" \
    "$dir"
done

SCAN_EXIT_CODE=$?

# Notify result.
if [ $SCAN_EXIT_CODE -eq 0 ]; then
  $CURL_BIN -s -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Nightly ClamAV scan completed successfully." "$NTFY_TOPIC"
else
  $CURL_BIN -s -d "⚠️ ${DEVICE_NAME} - ClamAV scan exited with code $SCAN_EXIT_CODE. Check logs." "$NTFY_TOPIC"
fi

exit $SCAN_EXIT_CODE
