#!/bin/bash

# --- Configuration ---
# Name of your Rclone remote for Google Drive
REMOTE_NAME="gdrive-personal"

# The folder on your Google Drive you want to expose
REMOTE_FOLDER="/Archive/Work/Zotero"

# The local address and port for the WebDAV server
WEBDAV_ADDR="localhost:8080"

# --- Security Configuration ---
WEBDAV_USERNAME="webdav"
WEBDAV_PASSWORD="2mdk^&slwmebdo"

# --- Script ---
echo "Starting Rclone WebDAV proxy..."
echo "Remote: ${REMOTE_NAME}:/${REMOTE_FOLDER}"
echo "Listening on: http://${WEBDAV_ADDR}"
echo "Username: ${WEBDAV_USERNAME}"
echo "Press Ctrl+C to stop the server."

rclone serve webdav ${REMOTE_NAME}:${REMOTE_FOLDER} \
    --addr ${WEBDAV_ADDR} \
    --user ${WEBDAV_USERNAME} \
    --pass ${WEBDAV_PASSWORD}
