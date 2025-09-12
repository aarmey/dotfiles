#!/bin/bash

# --- Configuration ---
LOCAL_BASE_DIR="/Volumes/Seagate 1/cloud-backup" # IMPORTANT: Change this to your desired local directory
RCLONE_CONFIG_FILE="$HOME/.config/rclone/rclone.conf" # Default rclone config location
RESTIC_REPO="/Volumes/Seagate 1/cloud-backup/restic" # IMPORTANT: Change this to your restic repository path
RESTIC_PASSWORD_FILE="$HOME/.restic_password" # IMPORTANT: Create this file with your restic password
                                            # or set RESTIC_PASSWORD environment variable

# Remote paths (as configured in rclone)
RCLONE_REMOTE_PERSONAL="drive-personal:"
RCLONE_REMOTE_WORK="box-work:"

# --- Script Start ---

echo "Starting cloud synchronization and backup script..."
echo "Local base directory: $LOCAL_BASE_DIR"

# Ensure the local base directory exists
mkdir -p "$LOCAL_BASE_DIR/drive-personal"
mkdir -p "$LOCAL_BASE_DIR/box-work"

# --- Syncing drive-personal ---
echo ""
echo "--- Syncing ${RCLONE_REMOTE_PERSONAL} to ${LOCAL_BASE_DIR}/drive-personal ---"
rclone sync \
    --config "$RCLONE_CONFIG_FILE" \
    --progress \
    --delete-excluded \
    --exclude ".DS_Store" \
    --exclude "/Arq Backup Data/**" \
    "$RCLONE_REMOTE_PERSONAL" \
    "${LOCAL_BASE_DIR}/drive-personal"

if [ $? -eq 0 ]; then
    echo "Synchronization of ${RCLONE_REMOTE_PERSONAL} completed successfully."
else
    echo "ERROR: Synchronization of ${RCLONE_REMOTE_PERSONAL} failed. Exiting."
    exit 1
fi

# --- Syncing box-work ---
echo ""
echo "--- Syncing ${RCLONE_REMOTE_WORK} to ${LOCAL_BASE_DIR}/box-work ---"
rclone sync \
    --config "$RCLONE_CONFIG_FILE" \
    --progress \
    --delete-excluded \
    --exclude ".DS_Store" \
    "$RCLONE_REMOTE_WORK" \
    "${LOCAL_BASE_DIR}/box-work"

if [ $? -eq 0 ]; then
    echo "Synchronization of ${RCLONE_REMOTE_WORK} completed successfully."
else
    echo "ERROR: Synchronization of ${RCLONE_REMOTE_WORK} failed. Exiting."
    exit 1
fi

# --- Restic Backup ---
echo ""
echo "--- Starting Restic Backup ---"
echo "Backing up: ${LOCAL_BASE_DIR}/drive-personal and ${LOCAL_BASE_DIR}/box-work"

export RESTIC_REPOSITORY="$RESTIC_REPO"
export RESTIC_PASSWORD_FILE="$RESTIC_PASSWORD_FILE"

# Check if restic repository needs initialization
if ! restic self-update > /dev/null 2>&1; then
    echo "Restic is not installed or not in PATH. Please install Restic."
    exit 1
fi

if ! restic snapshots > /dev/null 2>&1; then
    echo "Restic repository not found or not initialized. Initializing repository..."
    restic init
    if [ $? -eq 0 ]; then
        echo "Restic repository initialized successfully."
    else
        echo "ERROR: Failed to initialize Restic repository. Exiting."
        exit 1
    fi
fi

# Perform the backup
restic backup \
    --progress \
    --tag "cloud-sync-backup" \
    --exclude "${LOCAL_BASE_DIR}/drive-personal/.DS_Store" \
    --exclude "${LOCAL_BASE_DIR}/box-work/.DS_Store" \
    "${LOCAL_BASE_DIR}/drive-personal" \
    "${LOCAL_BASE_DIR}/box-work"

if [ $? -eq 0 ]; then
    echo "Restic backup completed successfully."
    echo ""
    echo "--- Restic Prune (optional, recommended for space saving) ---"
    # Example policy: keep 7 daily, 4 weekly, 12 monthly, all yearly
    restic forget \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 1 \
        --prune
    if [ $? -eq 0 ]; then
        echo "Restic prune completed successfully."
    else
        echo "WARNING: Restic prune failed. Check logs for details."
    fi
else
    echo "ERROR: Restic backup failed. Check logs for details."
    exit 1
fi

echo ""
echo "Script finished."
