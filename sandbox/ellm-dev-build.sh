#!/bin/bash
# Build/rebuild ellm-dev image and create container
# Use this after Dockerfile changes
# Run from: ~/git/ellm-sandbox/sandbox/

set -e

CONTAINER_NAME="ellm-dev"
IMAGE_NAME="ellm-dev"
GIT_MOUNT="$HOME/git:/workspace/git"

# Determine Docker bridge gateway IP so fs_proxy is only reachable via the bridge
# (accessible to containers using host.docker.internal, not exposed to LAN).
# Abort if the IP cannot be determined — an empty value would cause Docker to
# fall back to 0.0.0.0, exposing fs_proxy to the LAN.
BRIDGE_IP=$(docker network inspect bridge --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}')
if [ -z "$BRIDGE_IP" ] || [ "$BRIDGE_IP" = "0.0.0.0" ]; then
    echo -e "\033[31mERROR: Could not determine Docker bridge IP. Aborting to prevent LAN exposure of fs_proxy.\033[0m"
    exit 1
fi
echo -e "\033[36mDocker bridge IP: $BRIDGE_IP\033[0m"

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
# fs_proxy is published only on the Docker bridge IP — reachable by Agent Home via
# host.docker.internal but not from the LAN. The sandbox has no access to Agent Home's
# port (bound to 127.0.0.1 only), enforcing the invariant that agents cannot reach the server API.
echo -e "\033[36mCreating container with ~/git mounted...\033[0m"
docker run -it \
    --name "$CONTAINER_NAME" \
    --add-host host.docker.internal:host-gateway \
    -p "${BRIDGE_IP}:8080:8080" \
    -v "$GIT_MOUNT" \
    "$IMAGE_NAME" \
    bash -c "cd /workspace/git/Agent-Home/mcp_tools && uv run fs_proxy.py --host 0.0.0.0 --allowed-host $CONTAINER_NAME & bash"
# TODO: host.docker.internal only required by letta at this point, remove when lettn't
