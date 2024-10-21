#!/bin/bash

# Array of log filepaths.
log_files=(
    "/home/henry/SharedFolder/Henry/Logs/clamav.log"
    "/home/henry/SharedFolder/Henry/Logs/backup_steamdeck_screenshots.log"
    "/home/henry/SharedFolder/Henry/Logs/Minecraft/resources.log"
    "/home/henry/SharedFolder/Henry/Logs/Minecraft/backup_logs.log"
)

# Path to the send_to_discord.py script.
discord_webhook_python="/home/henry/Software/sftp_checkup_homepage/app/send_to_discord.py"

# Get the current date.
current_time=$(date +%s)

# Set the time threshold to 5 days in seconds (5 days * 24 hours * 60 minutes * 60 seconds)
threshold=$((5 * 24 * 60 * 60))

# Loop through each log file and check its last modification time.
for log_file in "${log_files[@]}"; do
    # If the file exists.
    if [[ -f "$log_file" ]]; then
        # Get the last modification time.
        last_mod_time=$(stat -c %Y "$log_file")
        
        # Calculate the difference in time between now and the last modification.
        time_diff=$((current_time - last_mod_time))
        
        # If the file hasn't been modified in more than 5 days, print a warning.
        if (( time_diff > threshold )); then
            log_filename=$(basename "$log_file")
            echo "WARNING: The log file '$log_filename' has not been updated in more than 5 days."
            python $discord_webhook_python "Cron Checker" "The log file '$log_filename' has not been updated in more than 5 days." "https://discord.com/api/webhooks/1279539607922409532/jUJmzeZNC41Cdz6twOf2jMWb-4SDYgIz7LdAanfb8iQVHrhnH4hxtxrq8lOzjbX1Y23L"
	else
            echo "INFO: The log file '$log_file' is up to date."
        fi
    else
        echo "ERROR: The log file '$log_file' does not exist."
    fi
done

