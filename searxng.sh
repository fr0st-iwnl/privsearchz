#!/bin/bash

# fr0st-iwnl

# Function to print a message
print_message() {
    echo "=================================="
    echo "$1"
    echo "=================================="
}

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Check if Docker is installed, and install it if not
if ! command -v docker &> /dev/null; then
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

# Start Docker service if it's not running
if ! systemctl is-active --quiet docker; then
    print_message "Starting Docker service..."
    systemctl start docker
    systemctl enable docker
fi

# Set your local IP address here
LOCAL_IP=""

# Pull the SearXNG Docker image
print_message "Pulling SearXNG Docker image..."
docker pull searxng/searxng

# Run SearXNG on the specified local IP and port 8080
print_message "Running SearXNG container on IP $LOCAL_IP..."
docker run -d \
    -p "$LOCAL_IP:8080:8080" \
    --name searxng-search \
    --restart unless-stopped \
    -e SEARXNG_BASE_URL="http://$LOCAL_IP:8080/" \
    searxng/searxng

# Confirmation message
print_message "SearXNG setup completed."
echo "You can access SearXNG at: http://$LOCAL_IP:8080"
