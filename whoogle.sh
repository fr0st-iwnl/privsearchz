#!/bin/bash

# fr0st-iwnl



# random print message
print_message() {
    echo "=================================="
    echo "$1"
    echo "=================================="
}

# run as root or its not gonna work
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# update package list and install Docker if not installed 
if ! command -v docker &> /dev/null
then
    print_message "Docker not found. Installing Docker..."
    # For Debian/Ubuntu-based systems
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y docker.io
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm docker
    # For RHEL/CentOS/Fedora-based systems
    elif command -v yum &> /dev/null; then
        yum install -y docker
    # Other systems
    else
        echo "Unsupported package manager. Please install Docker manually."
        exit 1
    fi
fi

# start Docker service if its not running
if ! systemctl is-active --quiet docker; then
    print_message "Starting Docker service..."
    systemctl start docker
    systemctl enable docker
fi

# put ur local ip addr here
LOCAL_IP=""

# pull the Whoogle Search Docker image
print_message "Pulling Whoogle Search Docker image..."
docker pull benbusby/whoogle-search

# run Whoogle Search on the local IP
print_message "Running Whoogle Search container on IP $LOCAL_IP..."
docker run -d \
   -p "$LOCAL_IP:5000:5000" \
   --name whoogle-search \
   --restart unless-stopped \
   -e WHOOGLE_CONFIG_LANGUAGE=en-US \
   -e WHOOGLE_CONFIG_THEME=dark \
   benbusby/whoogle-search

# confirmation message
print_message "Whoogle Search setup completed."
echo "You can access Whoogle Search at: http://$LOCAL_IP:5000"
