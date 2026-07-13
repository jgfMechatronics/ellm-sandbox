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

# Install Python 3.13 via uv (Letta requires <3.14)
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
RUN uv python install 3.13

# Create non-root user matching host UID/GID
RUN groupadd -g 1000 ellm && \
    useradd -u 1000 -g 1000 -m -s /bin/bash ellm

USER ellm

# Environment
ENV COLORTERM="truecolor"

# Entry point
CMD ["bash"]
