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

# Install uv (to /usr/local/bin so non-root users can access it)
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

# Install Python 3.13 via uv (required by Letta)
# UV_PYTHON_INSTALL_DIR puts the interpreter in /opt; chown lets ellm download more versions on demand
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
RUN uv python install 3.13 && chmod -R a+w /opt/uv/python

# Create shared Python venv for scripts (group_chat.py etc.)
RUN uv venv /opt/ellm --python 3.13 && \
    uv pip install --python /opt/ellm/bin/python3 \
        prompt_toolkit  # group_chat.py
ENV PATH="/opt/ellm/bin:$PATH"

# Install agent-commit script for clean git identity
COPY agent-commit /opt/ellm/bin/agent-commit
RUN chmod +x /opt/ellm/bin/agent-commit

# Install Letta Code from local build
COPY letta-ai-letta-code-0.15.6.tgz /tmp/letta-code.tgz
RUN npm install -g /tmp/letta-code.tgz && rm /tmp/letta-code.tgz

# Create non-root user matching host UID/GID
RUN groupadd -g 1000 ellm && \
    useradd -u 1000 -g 1000 -m -s /bin/bash ellm

# Pre-configure LC with pinned agents (Opus + Sonnet)
RUN mkdir -p /home/ellm/.letta && chown ellm:ellm /home/ellm/.letta
COPY --chown=ellm:ellm letta-settings.json /home/ellm/.letta/settings.json

USER ellm

# Set working directory
WORKDIR /workspace

# Environment
ENV TERM="xterm-256color"
ENV LETTA_BASE_URL="http://host.docker.internal:8283"
ENV COLORTERM="truecolor"
ENV DISABLE_AUTOUPDATER="1"

# Entry point
CMD ["bash"]
