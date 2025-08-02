#!/bin/bash

# Variables.
SOURCE_FILE="/var/log/secure"
DEST_DIR="/home/henry/SharedFolder/Henry/Logs/SSH"
DATE_TIME=$(date +"%Y-%m-%d-%H-%M")
DEST_FILE="${DEST_DIR}/secure_${DATE_TIME}.log"
USER="henry"
GROUP="henry"
PERMISSIONS="644"

# Copy the file.
cp $SOURCE_FILE $DEST_FILE

# Change ownership.
chown $USER:$GROUP $DEST_FILE

# Change permissions.
chmod $PERMISSIONS $DEST_FILE

# Print success message.
echo "File copied and permissions set successfully."

# Delete old backups.
BACKUP_COUNT=$(ls ${DEST_DIR}/secure_* | wc -l)
MAX_BACKUPS=10

# Check if the number of backups exceeds the maximum allowed
if [ $BACKUP_COUNT -gt $MAX_BACKUPS ]; then
    # Find and delete the oldest backup
    OLDEST_BACKUP=$(ls -t ${DEST_DIR}/secure_* | tail -1)
    rm $OLDEST_BACKUP
    echo "Deleted oldest backup: $OLDEST_BACKUP"
fi
