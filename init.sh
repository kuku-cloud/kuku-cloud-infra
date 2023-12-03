#!/bin/bash

# Define the output path for kubeconfig
KUBECONFIG_OUTPUT="$(pwd)/kubeconfig.yaml"

# Function to start K3s and Rancher using Docker Compose
start_services() {
    echo "Starting K3s and Rancher..."
    docker-compose up -d
}

# Function to stop K3s and Rancher
stop_services() {
    echo "Stopping K3s and Rancher containers..."
    docker-compose down
}

# Check if K3s container is already running
if [ $(docker ps -q -f name=k3s) ]; then
    echo "Found existing K3s container."
    read -p "Do you want to restart K3s and Rancher? [y/N]: " confirm
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        stop_services
        start_services
    else
        echo "Skipping services restart."
    fi
else
    start_services
fi

# Wait for the K3s container to start
echo "Waiting for the K3s container to start..."
sleep 30  # Wait for 30 seconds to ensure K3s is fully up

# Extract the kubeconfig file
echo "Extracting kubeconfig file..."
docker-compose exec k3s cat /etc/rancher/k3s/k3s.yaml > "${KUBECONFIG_OUTPUT}"

# Replace the default server address in the kubeconfig file
echo "Updating kubeconfig file..."
sed -i '' "s/default:6443/localhost:6443/g" "${KUBECONFIG_OUTPUT}"

# Update the KUBECONFIG environment variable for the current session
echo "Setting KUBECONFIG environment variable for the current session..."
export KUBECONFIG="${KUBECONFIG_OUTPUT}"

# Deploy Ingress service in advance
echo "Deploying Ingress controller from GitHub repository..."
kubectl apply -f https://raw.githubusercontent.com/kuku-cloud/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

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
