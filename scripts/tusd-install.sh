#!/bin/bash

# Define where to save the tusd binary
TUSD_BIN_PATH="/usr/local/bin/tusd"

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

# Clean up downloaded and extracted files
rm -rf tusd.tar.gz tusd_linux_amd64

echo "tusd setup completed. tusd is now available at ${TUSD_BIN_PATH}"
