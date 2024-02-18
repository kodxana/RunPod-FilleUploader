#!/bin/bash

# Define where to save the tusd binary
TUSD_BIN_PATH="/usr/local/bin/tusd"

# Define the directory for hooks
HOOKS_DIR="/etc/tusd/hooks"

# Create the hooks directory
mkdir -p "${HOOKS_DIR}"

# Download the tusd tar.gz file
echo "Downloading tusd..."
curl -L https://github.com/tus/tusd/releases/download/v2.2.2/tusd_linux_amd64.tar.gz -o tusd.tar.gz

# Extract the tusd binary
echo "Extracting tusd..."
tar -xzf tusd.tar.gz tusd_linux_amd64/tusd

# Move the tusd binary to the desired location
echo "Setting up tusd..."
mv tusd_linux_amd64/tusd "${TUSD_BIN_PATH}"

# Make tusd executable
chmod +x "${TUSD_BIN_PATH}"

# Download hook scripts
echo "Downloading hook scripts..."
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/hook/post-finish -o "${HOOKS_DIR}/post-finish"
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/hook/rename_uploaded_file.py -o "${HOOKS_DIR}/rename_uploaded_file.py"

# Make the hook scripts executable
echo "Setting up hook scripts..."
chmod +x "${HOOKS_DIR}/post-finish"
chmod +x "${HOOKS_DIR}/rename_uploaded_file.py"

# Clean up downloaded and extracted files
rm -rf tusd.tar.gz tusd_linux_amd64

echo "tusd setup completed. tusd is now available at ${TUSD_BIN_PATH}"
echo "Hook scripts are set up at ${HOOKS_DIR}"
