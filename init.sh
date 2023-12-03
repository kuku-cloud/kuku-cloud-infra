#!/bin/bash

# Define the output path for kubeconfig
KUBECONFIG_OUTPUT="$(pwd)/kubeconfig.yaml"

# Function to start K3s using Docker Compose
start_k3s() {
    echo "Starting K3s..."
    docker-compose up -d
}

# Function to stop K3s
stop_k3s() {
    echo "Stopping existing K3s container..."
    docker-compose down
}

# Check if K3s container is already running
if [ $(docker ps -q -f name=k3s) ]; then
    echo "Found existing K3s container."
    read -p "Do you want to restart K3s? [y/N]: " confirm
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        stop_k3s
        start_k3s
    else
        echo "Skipping K3s restart."
    fi
else
    start_k3s
fi

# Wait for the K3s container to start
echo "Waiting for the K3s container to start..."
sleep 30  # Wait for 30 seconds to ensure K3s is fully up

# Extract the kubeconfig file
echo "Extracting kubeconfig file..."
docker-compose exec k3s cat /etc/rancher/k3s/k3s.yaml > kubeconfig.yaml

# Replace the default server address in the kubeconfig file
echo "Updating kubeconfig file..."
sed -i '' "s/default:6443/localhost:6443/g" "${KUBECONFIG_OUTPUT}"

# Update the KUBECONFIG environment variable for the current session
echo "Setting KUBECONFIG environment variable for the current session..."
export KUBECONFIG="${KUBECONFIG_OUTPUT}"

# Test the kubectl configuration
echo "Testing kubectl configuration..."
kubectl cluster-info

# Output the result
if [ $? -eq 0 ]; then
    echo "K3s cluster initialized successfully!"
else
    echo "K3s cluster initialization failed."
fi

# Optional: Update this script to include instructions for users to set KUBECONFIG in their own environment
echo "Remember to set 'export KUBECONFIG=${KUBECONFIG_OUTPUT}' in your shell or add it to your profile script."
