FROM debian:bookworm-slim

# Install system deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Python 3.13 via uv (Letta requires <3.14)
RUN uv python install 3.13

# Install Letta Code from local build
COPY letta-ai-letta-code-0.15.6.tgz
RUN npm install -g /tmp/letta-code.tgz && rm /tmp/letta-code.tgz

# Set working directory
WORKDIR /workspace

# Pre-configure LC with pinned agents (Opus + Sonnet)
RUN mkdir -p /root/.letta
COPY letta-settings.json /root/.letta/settings.json

# Environment
ENV LETTA_BASE_URL="http://host.docker.internal:8283"
ENV TERM="xterm-256color"
ENV COLORTERM="truecolor"
ENV DISABLE_AUTOUPDATER="1"

# Entry point
CMD ["bash"]
