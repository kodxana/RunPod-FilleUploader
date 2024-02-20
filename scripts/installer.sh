#!/bin/bash

# Define where to save the binaries
TUSD_BIN_PATH="/usr/local/bin/tusd"
RUNPOD_UPLOADER_BIN_PATH="/usr/local/bin/runpod-uploader"
RUNPOD_UPLOADER_SCRIPT_PATH="/etc/runpod-uploader/scripts"

# Define the directory for hooks
HOOKS_DIR="/etc/tusd/hooks"

# Create the hooks directory
mkdir -p "${HOOKS_DIR}"

# Create the scripts directory
mkdir -p "${RUNPOD_UPLOADER_SCRIPT_PATH}"

# Download and setup tusd
echo "Downloading and setting up tusd..."
curl -L https://github.com/tus/tusd/releases/download/v2.2.2/tusd_linux_amd64.tar.gz -o tusd.tar.gz
tar -xzf tusd.tar.gz tusd_linux_amd64/tusd
mv tusd_linux_amd64/tusd "${TUSD_BIN_PATH}"
chmod +x "${TUSD_BIN_PATH}"

# Download and setup runpod-uploader binary
echo "Downloading and setting up runpod-uploader binary..."
curl -L https://github.com/kodxana/RunPod-FilleUploader/releases/download/v1.1/runpod-uploader -o "${RUNPOD_UPLOADER_BIN_PATH}"
chmod +x "${RUNPOD_UPLOADER_BIN_PATH}"

# Download and setup hook scripts
echo "Downloading and setting up hook scripts..."
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/hook/post-finish -o "${HOOKS_DIR}/post-finish"
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/hook/rename_uploaded_file.py -o "${HOOKS_DIR}/rename_uploaded_file.py"
chmod +x "${HOOKS_DIR}/post-finish"
chmod +x "${HOOKS_DIR}/rename_uploaded_file.py"
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/scripts/ssh-setup.sh -o "${RUNPOD_UPLOADER_SCRIPT_PATH}/ssh-setup.sh"
curl -L https://github.com/kodxana/RunPod-FilleUploader/raw/main/scripts/run-speedtest.sh -o "${RUNPOD_UPLOADER_SCRIPT_PATH}/run-speedtest.sh"
chmod +x "${RUNPOD_UPLOADER_SCRIPT_PATH}/ssh-setup.sh"
chmod +x "${RUNPOD_UPLOADER_SCRIPT_PATH}/run-speedtest.sh"

# Clean up downloaded and extracted files
rm -rf tusd.tar.gz tusd_linux_amd64

echo "Setup completed successfully."
echo "tusd is now available at ${TUSD_BIN_PATH}"
echo "runpod-uploader is now available at ${RUNPOD_UPLOADER_BIN_PATH}"
echo "Hook scripts are set up at ${HOOKS_DIR}"
echo "Aditional scripts saved to ${RUNPOD_UPLOADER_SCRIPT_PATH}"
