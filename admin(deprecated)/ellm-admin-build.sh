#!/bin/bash
# Build/rebuild ellm-admin image and create container
# Use this after Dockerfile changes
# Run from: ~/git/ellm-sandbox/admin/

set -e

CONTAINER_NAME="ellm-admin"
IMAGE_NAME="ellm-admin"
GIT_MOUNT="$HOME/git:/workspace/git"

# Colors
YELLOW='\033[33m'
CYAN='\033[36m'
RED='\033[31m'
NC='\033[0m'

# Stop and remove existing container if present
if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Removing existing container...${NC}"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME"
fi

# Build image
echo -e "${CYAN}Building image...${NC}"
docker build -t "$IMAGE_NAME" .

# Create and start container
# CRITICAL: --add-host flag required on Linux (Windows Docker Desktop injects this automatically)
echo -e "${CYAN}Creating container with ~/git mounted...${NC}"
docker run -it \
    --name "$CONTAINER_NAME" \
    --add-host host.docker.internal:host-gateway \
    -v "$GIT_MOUNT" \
    "$IMAGE_NAME"
