#!/bin/bash

WATCH_DIR="/home/casa/locations/sync"
NTFY_TOPIC="whale_server_1"
BUFFER_TIME=15  # Seconds to batch events

event_file=$(mktemp)

trap "rm -f $event_file" EXIT

# Background process to summarize and send notifications
(
    while true; do
        if [[ -s $event_file ]]; then
            # Extract and count CREATE and DELETE events
            read create_count delete_count <<< $(sort "$event_file" | uniq | \
                awk -F'[()]' '{ print $2 }' | tr ',' '\n' | \
                awk '
                    BEGIN { create=0; del=0 }
                    $1 == "CREATE" { create += 1 }
                    $1 == "DELETE" { del += 1 }
                    END { print create, del }')


            summary=""

            if (( create_count > 0 )); then
                if (( create_count == 1 )); then
                    summary+="1 new file"
                else
                    summary+="$create_count new files"
                fi
            fi

            if (( delete_count > 0 )); then
                if [[ -n "$summary" ]]; then summary+=" and "; fi
                if (( delete_count == 1 )); then
                    summary+="1 file deleted"
                else
                    summary+="$delete_count files deleted"
                fi
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
inotifywait -m -r -e create -e delete --format '%w%f (%e)' "$WATCH_DIR" |
while read FILE_EVENT; do
    echo "$FILE_EVENT" >> "$event_file"
done
