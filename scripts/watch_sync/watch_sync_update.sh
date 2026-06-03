#!/bin/bash


NTFY_FILE="/home/software/repositories/server_scripts/ntfy_location.txt"
NTFY_TOPIC="$(cat "$NTFY_FILE")"

WATCH_DIR="/home/casa/locations/sync"
BUFFER_TIME=600  # Seconds to batch events

event_file=$(mktemp)
trap "rm -f $event_file" EXIT

# Background process to summarize and send notifications
(
    while true; do
        if [[ -s $event_file ]]; then
            read create_count delete_count <<< $(sort "$event_file" | uniq | \
                awk -F'|' '{ print $2 }' | \
                awk '
                    BEGIN { create=0; del=0 }
                    $1 ~ /CREATE/ { create += 1 }
                    $1 ~ /DELETE/ || $1 ~ /MOVED_FROM/ { del += 1 }
                    END { print create, del }')

            summary=""

            if (( create_count > 0 )); then
                summary+="$create_count new file"
                [[ $create_count -gt 1 ]] && summary+="s"
            fi

            if (( delete_count > 0 )); then
                [[ -n "$summary" ]] && summary+=" and "
                summary+="$delete_count file"
                [[ $delete_count -gt 1 ]] && summary+="s"
                summary+=" deleted"
            fi

            if [[ -n "$summary" ]]; then
                curl -d "📂 Whale Server - Sync directory change. $summary." ntfy.sh/$NTFY_TOPIC
            fi

            > "$event_file"  # Clear buffer
        fi

        sleep "$BUFFER_TIME"
    done
) &

# Watch for file events
inotifywait -m -r \
    -e create -e delete -e move --format '%w%f|%e' "$WATCH_DIR" |
while IFS='|' read -r FILE EVENT; do
    echo "$FILE|$EVENT" >> "$event_file"
done
