#!/bin/bash

# Function to print in color
print_color() {
    COLOR=$1
    TEXT=$2
    case $COLOR in
        "green") echo -e "\e[32m$TEXT\e[0m" ;;
        "red") echo -e "\e[31m$TEXT\e[0m" ;;
        "yellow") echo -e "\e[33m$TEXT\e[0m" ;;
        "blue") echo -e "\e[34m$TEXT\e[0m" ;;
        *) echo "$TEXT" ;;
    esac
}

# Check for OS Type
print_color "blue" "Detecting Linux Distribution..."
os_info=$(cat /etc/*release)
print_color "yellow" "OS Detected: $os_info"

# Check for SSH Server and install if necessary
if ! command -v sshd >/dev/null; then
    print_color "yellow" "SSH server not found. Installing..."
    if [[ $os_info == *"debian"* || $os_info == *"ubuntu"* ]]; then
        apt-get update && apt-get install -y openssh-server
    elif [[ $os_info == *"redhat"* || $os_info == *"centos"* ]]; then
        yum install -y openssh-server
    else
        print_color "red" "Unsupported Linux distribution for automatic SSH installation."
        exit 1
    fi
    print_color "green" "SSH Server Installed Successfully."
else
    print_color "green" "SSH Server is already installed."
fi

# Configure SSH to allow root login
print_color "blue" "Configuring SSH to allow root login with a password..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart
print_color "green" "SSH Configuration Updated."

# Generate random password for root and save it
print_color "blue" "Generating a secure random password for root..."
root_password=$(openssl rand -base64 12)
echo "root:$root_password" | chpasswd
echo $root_password > /workspace/root_password.txt
print_color "green" "Root password generated and saved in /workspace/root_password.txt"

# Check if environment variables are set
print_color "blue" "Checking environment variables..."
if [ -z "$RUNPOD_PUBLIC_IP" ] || [ -z "$RUNPOD_TCP_PORT_22" ]; then
    print_color "red" "Environment variables RUNPOD_PUBLIC_IP or RUNPOD_TCP_PORT_22 are missing."
    exit 1
fi
print_color "green" "Environment variables are set."

# Create connection script for Windows (.bat)
print_color "blue" "Creating connection script for Windows..."
echo "@echo off" > /workspace/connect_windows.bat
echo "echo Root password: $root_password" >> /workspace/connect_windows.bat
echo "ssh root@$RUNPOD_PUBLIC_IP -p $RUNPOD_TCP_PORT_22" >> /workspace/connect_windows.bat
print_color "green" "Windows connection script created in /workspace."

# Create connection script for Linux/Mac (.sh)
print_color "blue" "Creating connection script for Linux/Mac..."
echo "#!/bin/bash" > /workspace/connect_linux.sh
echo "echo Root password: $root_password" >> /workspace/connect_linux.sh
echo "ssh root@$RUNPOD_PUBLIC_IP -p $RUNPOD_TCP_PORT_22" >> /workspace/connect_linux.sh
chmod +x /workspace/connect_linux.sh
print_color "green" "Linux/Mac connection script created in /workspace."

print_color "green" "Setup Completed Successfully!"
