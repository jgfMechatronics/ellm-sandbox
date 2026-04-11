#!/usr/bin/env bash
# Build a LettaCode tarball from source and place it in the sandbox directory.
# Run from inside a Linux container that has C:\Git mounted at /workspace/git.
#
# Usage: bash /workspace/git/ellm-sandbox/sandbox/build-lc-tarball.sh

set -e

LETTA_CODE_DIR="/workspace/git/LettaCode"
SANDBOX_DIR="/workspace/git/ellm-sandbox/sandbox"

# --- Install bun if needed ---
if ! command -v bun &> /dev/null; then
    echo ">>> bun not found, installing..."
    apt-get install -y unzip -qq
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
else
    echo ">>> bun already installed: $(bun --version)"
fi

export PATH="$HOME/.bun/bin:$PATH"

# --- Build ---
echo ">>> Building LettaCode..."
cd "$LETTA_CODE_DIR"
bun run build

# --- Pack ---
echo ">>> Packing..."
npm pack

# --- Move tarball to sandbox ---
TARBALL=$(ls letta-ai-letta-code-*.tgz | tail -1)
echo ">>> Moving $TARBALL to $SANDBOX_DIR..."
mv "$TARBALL" "$SANDBOX_DIR/"

# --- Update Dockerfile COPY line ---
DOCKERFILE="$SANDBOX_DIR/Dockerfile"
echo ">>> Updating Dockerfile COPY line to $TARBALL..."
sed -i "s/COPY letta-ai-letta-code-.*\.tgz/COPY $TARBALL/" "$DOCKERFILE"

echo ">>> Done: $SANDBOX_DIR/$TARBALL"
