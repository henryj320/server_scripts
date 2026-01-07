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

# Directories to Ignore.
EXCLUDE_DIRS=("Education" "Housing" "pictures" "Nothing Phone 2" "University")

PRUNE_EXPR=()
for d in "${EXCLUDE_DIRS[@]}"; do
  PRUNE_EXPR+=( -name "$d" -o )
done
unset 'PRUNE_EXPR[${#PRUNE_EXPR[@]}-1]'
# -------------------------------

# Log header.
$ECHO_BIN -e "\n\n\n" >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started." >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started."

SCAN_EXIT_CODE=0
START_TIME=$($DATE_BIN +%s)


$ECHO_BIN "$($DATE_BIN) - Scanning $SCAN_PATH (with pruned exclusions)" >> "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Scanning $SCAN_PATH (with pruned exclusions)"

if ! find "$SCAN_PATH" \
  \( -type d \( "${PRUNE_EXPR[@]}" \) -prune \) -o \
  -type f -print0 |
  xargs -0 -r "$CLAMDSCAN_BIN" \
    --verbose \
    --remove \
    --infected \
    --multiscan \
    --log="$LOG_FILE"
then
  SCAN_EXIT_CODE=2
fi

DIR_COUNT=$(find "$SCAN_PATH" -mindepth 1 -maxdepth 1 -type d | wc -l)

# Timing
END_TIME=$($DATE_BIN +%s)
DURATION_SECONDS=$((END_TIME - START_TIME))
DURATION_MINUTES=$((DURATION_SECONDS / 60))
DURATION_REMAINDER_SECONDS=$((DURATION_SECONDS % 60))
RUNTIME_FMT="${DURATION_MINUTES} minutes and ${DURATION_REMAINDER_SECONDS} seconds"

# Final Ntfy
if [ $SCAN_EXIT_CODE -eq 0 ]; then
  $CURL_BIN -s -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Nightly ClamAV scan completed successfully. $DIR_COUNT directories scanned in ${RUNTIME_FMT}." "$NTFY_TOPIC"
else
  $CURL_BIN -s -d "⚠️ ${DEVICE_NAME} - ClamAV scan encountered errors. Directories scanned: $DIR_COUNT in ${RUNTIME_FMT}." "$NTFY_TOPIC"
fi

exit $SCAN_EXIT_CODE
