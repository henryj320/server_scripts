# Server Status

The purpose of this is to ` notify-send ` messages on other computers when the Rocky Server is performing a job.

## Files

It consists of three files:

- ***server_status.json***: A JSON file containing the current job.
- ***update_server_status.sh***: A script to take the fields as arguments and update *server_status.json*.
- ***auto_update_server_status.sh***: A basic script to reset the *server_status.json* after 5 minutes.

---

## Process

The basic process is as follows:

### Rocky Server

1. The Rocky Server starts a job and updates *server_status.json*.
2. The Rocky Server also starts *auto_update_server_status.sh* at the same time
3. After 5 minutes, *auto_update_server_status.sh* will automatically reset *server_status.json*.

### Other Computers

1. A cron runs every 5 minutes to check whether *server_status.json* has updated.
2. If it has updated, then ` notify-send ` the current job.
