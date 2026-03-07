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

# Install Letta Code (pinned - 0.17.1 has default conversation bug)
RUN npm install -g @letta-ai/letta-code@0.15.6

# Set working directory
WORKDIR /workspace

# Default to connecting to host Letta server
ENV LETTA_BASE_URL="http://host.docker.internal:8283"

# Entry point
CMD ["bash"]
