#!/bin/bash

# --- Configuration ---
# Name of your Rclone remote for Box
REMOTE_NAME="box-work"

# The folder on your Box you want to expose
REMOTE_FOLDER="/Archive/Zotero"

# --- Security Configuration ---
WEBDAV_USERNAME="webdav"
WEBDAV_PASSWORD="2mdk^&slwmebdo"

# --- Script ---
echo "Starting Rclone WebDAV proxy..."
echo "Remote: ${REMOTE_NAME}:/${REMOTE_FOLDER}"
echo "Listening on localhost and tailscale at 8080"
echo "Username: ${WEBDAV_USERNAME}"
echo "Press Ctrl+C to stop the server."

rclone serve webdav ${REMOTE_NAME}:${REMOTE_FOLDER} \
    --addr 100.106.19.88:8080 \
    --addr 127.0.0.1:8080 \
    --user ${WEBDAV_USERNAME} \
    --pass ${WEBDAV_PASSWORD}
