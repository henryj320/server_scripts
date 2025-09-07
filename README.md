# server_scripts

Last update: 2025-07-31 23:53
<br><br>

A collection of unrelated scripts used by the Whale Server.

## server_scripts

**Title**: homepage_endpoints

**Date Started**: 2024-10-21

**Date Completed**: 2024-11-16

**Language**: Bash

**Overview**: A collection of unrelated scripts used by the Whale Server or other Linux computers. These include:

### Rocky Server

- **backup_secure_file.sh**:
    - Copies "/var/log/secure" onto the SMB drive.
- **check_dnf_updates.sh**:
    - Sends a Discord message if there are any important or critical DNF updates.
- **check_logs.sh**:
    - Sends a Discord message if a cron has failed. Detected by log files not updating.
- **resize_steam.sh**:
    - Used on the Gaming PC to automatically resize Steam. Fixes visual glitches caused by Nvidia drivers.
- **run_clamscan.sh**:
    - Runs ClamAV as an antivirus checker. Outputs the results into log files and the Homepage.
- **send_game_screenshot.sh**
    - Use *send_to_discord.py* with its new image-sending functionality to send any screenshots uploaded to a specific folder onto the Discord server.
- **virusEvent.sh**:
    - Used to send an alert to Homepage on a virus event.
- **watch_sync_update.sh**:
    - Sends a Ntfy message if "/home/casa/locations/sync" has any file creations or deletions.
- **sync_to_proton_drive.sh**:
    - Uploads server content to a pre-configured Proton Drive and notifies Ntfy on completion.

### KDE Desktop

- **mic-auto-switch.sh**
    - Monitor for an active Discord (Vesktop client) call and switch output from speakers to headphones.
