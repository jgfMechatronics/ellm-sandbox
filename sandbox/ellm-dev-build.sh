#!/bin/bash
# Build/rebuild ellm-dev image and create container
# Use this after Dockerfile changes
# Run from: ~/git/ellm-sandbox/sandbox/

set -e

# Load .env if present (allows overriding AGENT_SANDBOX_CONTAINER_NAME and ELLM_AGENT_NETWORK)
if [ -f .env ]; then
    set -a && source .env && set +a
fi

CONTAINER_NAME="${AGENT_SANDBOX_CONTAINER_NAME:-ellm-dev}"
NETWORK_NAME="${ELLM_AGENT_NETWORK:-agent-home_container_net}"
IMAGE_NAME="ellm-dev"
GIT_MOUNT="$HOME/git:/workspace/git"

# Create Docker network if it doesn't exist
docker network inspect "$NETWORK_NAME" > /dev/null 2>&1 || {
    echo -e "\033[36mCreating Docker network '$NETWORK_NAME'...\033[0m"
    docker network create "$NETWORK_NAME"
}

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
# NOTE: -p 8080:8080 intentionally omitted — fs_proxy is only reachable within the Docker network,
#       preventing LAN exposure of the unauthenticated MCP endpoint.
echo -e "\033[36mCreating container with ~/git mounted...\033[0m"
docker run -it \
    --name "$CONTAINER_NAME" \
    --network "$NETWORK_NAME" \
    --add-host host.docker.internal:host-gateway \
    -v "$GIT_MOUNT" \
    "$IMAGE_NAME" \
    bash -c "cd /workspace/git/Agent-Home/mcp_tools && uv run fs_proxy.py --host 0.0.0.0 --allowed-host $CONTAINER_NAME & bash"
# TODO: host.docker.internal only required by letta at this point, remove in favor of pure container network when lettn't

