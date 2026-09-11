# server_scripts

A collection of unrelated scripts used by the Whale Server. These are both actively in use and decommissioned.

**Date Started**: 2024-10-21

## Docker Containers

These are now unused. They are backup *docker-compose.yml* and volumes from my previous Rocky 8 server.

---

## KDE Desktop

This contains various scripts used by my personal devices. Mostly to automate small tasks like switching to headphones when a Discord call starts.

- **toggle-headphones.sh**
  - Automatically switch to/from headphones when the script runs.

- **move-virtual-monitors.sh**
  - Adjusts the dual monitors to be diagonal instead of side-to-side. Minimises the mouse accidentally going to the wrong screen in Embark games.

- **resize-steam.sh**
  - Now unused. Resizes steam to the correct size when the PC starts. KDE window settings were not working.

- **switch-to-headphones.sh**
  - Not working in Gnome. Switch to headphones when a game starts and then switch back when the game closes.

- **mic-auto-switch.sh**
  - Monitor for an active Discord (Vesktop client) call and switch output from speakers to headphones.

- **monitor-headphone-battery.sh**
  - Used for 2.4 GHz headphones where Bluetooth battery indication is not working. Records when headphones are being used in order to estimate remaining charge and notify when at low charge.

- **night-volume.sh**
  - Decrease volume to a set amount at nighttime, and increase again in daytime.

---

## Scripts

- **backup-secure-file.sh**:
  - Copies "/var/log/secure" onto the SMB drive. Currently unused.

- **sync-to-proton-drive.sh**:
  - Uploads server content to a pre-configured Proton Drive and notifies Ntfy on completion. Currently unused as uploading to Proton Drive is temperamental.

- **run-clamscan.sh**:
  - Runs ClamAV as an antivirus checker. Outputs the results into log files.

- **check-apt-updates.sh**
  - Returns whether there are apt updates.

- **check-dnf-updates.sh**:
  - Sends a message if there are any important or critical DNF updates.

- **watch-sync-update.sh**:
  - Sends a Ntfy message if "/home/casa/locations/sync" has any file creations or deletions.

---

