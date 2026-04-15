#!/bin/bash

SCAN_PATH="/home/casa/locations"
LOG_FILE="/home/casa/locations/logs/ClamAV/removed_files.log"


NTFY_FILE="/home/software/repositories/server_scripts/ntfy_location.txt"
ntfy_channel="$(cat "$NTFY_FILE")"

NTFY_TOPIC="https://ntfy.sh/$ntfy_channel"

DEVICE_EMOJI="🛡️"
DEVICE_NAME="Whale Server"

CLAMDSCAN_BIN="/usr/bin/clamdscan"
DATE_BIN="/usr/bin/date"
ECHO_BIN="/usr/bin/echo"
CURL_BIN="/usr/bin/curl"

# Build prune expression used to exclude directories.
EXCLUDE_DIRS=("Education" "Housing" "pictures" "Nothing Phone 2" "University")
PRUNE_EXPR=()
for d in "${EXCLUDE_DIRS[@]}"; do
  PRUNE_EXPR+=( -name "$d" -o )
done
unset 'PRUNE_EXPR[${#PRUNE_EXPR[@]}-1]'

# Clean header for the log file.
$ECHO_BIN -e "\n\n\n" | tee -a "$LOG_FILE"
$ECHO_BIN -e "------------------------------------------------------------------------------------------------------------------------\n" | tee -a "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Nightly scan of $SCAN_PATH started." | tee -a "$LOG_FILE"
$ECHO_BIN "$($DATE_BIN) - Scanning $SCAN_PATH (with pruned exclusions)" | tee -a "$LOG_FILE"
$ECHO_BIN -e "\n$($DATE_BIN) - Skipped subdirectories:" | tee -a "$LOG_FILE"
find "$SCAN_PATH" -type d \( "${PRUNE_EXPR[@]}" \) -print | tee -a "$LOG_FILE"

SCAN_EXIT_CODE=0
START_TIME=$($DATE_BIN +%s)

# Build a list of directories to run clamdscan on.
SCAN_DIRS=()
for dir in "$SCAN_PATH"/*; do
  [ -d "$dir" ] || continue
  base="$(basename "$dir")"

  # Skip top-level excluded directories.
  if [[ " ${EXCLUDE_DIRS[*]} " =~ " $base " ]]; then
    continue
  fi

  SCAN_DIRS+=("$dir")
done

# Output all directories that will be scanned for logging.
$ECHO_BIN -e "\n$($DATE_BIN) - Directories that will be scanned:" | tee -a "$LOG_FILE"
for d in "${SCAN_DIRS[@]}"; do
  $ECHO_BIN "  SCAN: $d" | tee -a "$LOG_FILE"
done
$ECHO_BIN -e "\n" | tee -a "$LOG_FILE"


# Run clamdscan on each directory in the list.
for dir in "${SCAN_DIRS[@]}"; do
  echo
  echo "===== Scanning directory: $dir =====" | tee -a "$LOG_FILE"

  if ! find "$dir" \
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
done

# Record how many directories are scanned.
DIR_COUNT=${#SCAN_DIRS[@]}

# Calculate how long it took.
END_TIME=$($DATE_BIN +%s)
DURATION_SECONDS=$((END_TIME - START_TIME))
DURATION_MINUTES=$((DURATION_SECONDS / 60))
DURATION_REMAINDER_SECONDS=$((DURATION_SECONDS % 60))
RUNTIME_FMT="${DURATION_MINUTES} minutes and ${DURATION_REMAINDER_SECONDS} seconds"

# Send the final Ntfy and log update.
if [ $SCAN_EXIT_CODE -eq 0 ]; then
  $CURL_BIN -s -d "${DEVICE_EMOJI} ${DEVICE_NAME} - Nightly ClamAV scan completed successfully. $DIR_COUNT directories scanned in ${RUNTIME_FMT}." "$NTFY_TOPIC"
  $ECHO_BIN -e "\n$($DATE_BIN) - Nightly ClamAV scan completed successfully. $DIR_COUNT directories scanned in ${RUNTIME_FMT}." | tee -a "$LOG_FILE"
else
  $CURL_BIN -s -d "⚠️ ${DEVICE_NAME} - ClamAV scan encountered errors. Directories scanned: $DIR_COUNT in ${RUNTIME_FMT}." "$NTFY_TOPIC"
  $ECHO_BIN -e "\n$($DATE_BIN) - ClamAV scan encountered errors. Directories scanned: $DIR_COUNT in ${RUNTIME_FMT}." | tee -a "$LOG_FILE"
fi

exit $SCAN_EXIT_CODE
