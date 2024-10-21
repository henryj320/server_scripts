#!/bin/bash

dnf check-update

# Get the list of security updates with Important and Critical severity.
updates=$(dnf updateinfo list --sec-severity=Important --sec-severity=Critical | tail -n +2)        

# Count the number of lines in the output.
count=$(echo "$updates" | wc -l)

# Check if there are any updates.
if [ "$count" -gt 1 ]; then

    webhook="https://discord.com/api/webhooks/1279539607922409532/jUJmzeZNC41Cdz6twOf2jMWb-4SDYgIz7LdAanfb8iQVHrhnH4hxtxrq8lOzjbX1Y23L"

    message="There are Important or Critical security updates available:\n$updates"
    formatted_message=$(printf "There are important or moderate security updates available:\n\n%s" "$updates")

    # Send a message to the Discord webhook.
    python /home/henry/Software/sftp_checkup_homepage/app/send_to_discord.py "DNF Update Checker" "$formatted_message" "$webhook"
fi
