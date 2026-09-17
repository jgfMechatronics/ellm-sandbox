FROM debian:bookworm-slim

# Install system deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    nano \
    clang \
    mold \
    pkg-config \
    libssl-dev \
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

# Create shared Python venv for scripts
RUN uv venv /opt/ellm --python 3.13 && \
    uv pip install --python /opt/ellm/bin/python3
ENV PATH="/opt/ellm/bin:$PATH"

# Install agent-commit script for clean git identity
COPY agent-commit /opt/ellm/bin/agent-commit
RUN chmod +x /opt/ellm/bin/agent-commit

# Create non-root user matching host UID/GID
RUN groupadd -g 1000 ellm && \
    useradd -u 1000 -g 1000 -m -s /bin/bash ellm

USER ellm

# Install Rust toolchain via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.90.0
ENV PATH="/home/ellm/.cargo/bin:$PATH"

# Set working directory
WORKDIR /workspace

# Environment
ENV TERM="xterm-256color"
ENV EDITOR="nano"
ENV COLORTERM="truecolor"
ENV DISABLE_AUTOUPDATER="1"

CMD ["bash"]
