#!/bin/bash
# Build/rebuild ellm-dev image and create container
# Use this after Dockerfile changes
# Run from: ~/git/ellm-sandbox/sandbox/

set -e

CONTAINER_NAME="ellm-dev"
IMAGE_NAME="ellm-dev"
GIT_MOUNT="$HOME/git:/workspace/git"

# Stop and remove existing container if present
if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "\033[33mRemoving existing container...\033[0m"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME"
fi

# Build image
echo -e "\033[36mBuilding image...\033[0m"
docker build -t "$IMAGE_NAME" .

# Create and start container
# CRITICAL: --add-host flag required on Linux (Windows Docker Desktop injects this automatically)
echo -e "\033[36mCreating container with ~/git mounted...\033[0m"
docker run -it \
    --name "$CONTAINER_NAME" \
    --add-host host.docker.internal:host-gateway \
    -v "$GIT_MOUNT" \
    "$IMAGE_NAME"
