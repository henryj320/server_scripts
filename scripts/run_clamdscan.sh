#!/bin/bash

SCAN_PATH="/home/casa/locations/documents/Configurations"
LOG_FILE="/home/casa/locations/logs/ClamAV/removed_files.log"

NTFY_TOPIC="https://ntfy.sh/whale_server_1"

DEVICE_EMOJI="🛡️"
DEVICE_NAME="Whale Server"

CLAMDSCAN_BIN="/usr/bin/clamdscan"
DATE_BIN="/usr/bin/date"
ECHO_BIN="/usr/bin/echo"
CURL_BIN="/usr/bin/curl"

# Directories to Ignore.
EXCLUDE_DIRS=("Education" "Housing")

# Log header.
$ECHO_BIN -e "\n\n\n" >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started." >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started."


# Run scan (directory-by-directory).
SCAN_EXIT_CODE=0
FAILED_DIRS=()
DIR_COUNT=0

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

  DIR_EXIT_CODE=$?
  if [ $DIR_EXIT_CODE -ne 0 ]; then
    SCAN_EXIT_CODE=1
    FAILED_DIRS+=("$dir")
  fi
  DIR_COUNT=$((DIR_COUNT + 1))
done

# Final Ntfy.
if [ $SCAN_EXIT_CODE -eq 0 ]; then
  $CURL_BIN -s -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Nightly ClamAV scan completed successfully. $DIR_COUNT directories scanned." "$NTFY_TOPIC"
else
  if [ ${#FAILED_DIRS[@]} -gt 0 ]; then
    FAILED_LIST=$(printf ", %s" "${FAILED_DIRS[@]}")
    FAILED_LIST=${FAILED_LIST:2}  # remove leading comma and space
  else
    FAILED_LIST="unknown directories"
  fi
  $CURL_BIN -s -d "⚠️ ${DEVICE_NAME} - ClamAV scan failed in: $FAILED_LIST. Directories scanned: $DIR_COUNT directories scanned." "$NTFY_TOPIC"
fi

exit $SCAN_EXIT_CODE
