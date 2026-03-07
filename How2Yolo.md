# YOLO Mode Dev Environment

*Working doc for sandboxed Letta Code execution*

---

## Problem

Running LC in YOLO mode (no approval prompts) is dangerous on an unsandboxed host. Agents can create/modify/delete files anywhere. Solution: run LC inside a Docker container so tool execution is isolated.

## Key Insight (verified)

Letta Code uses **client-side tool execution**:
- **Agent brain** (memory, state) → lives on Letta server
- **Tool execution** (Bash, Read, Write, Edit) → runs where LC runs

If LC runs in a Docker container pointing at James's server via `LETTA_BASE_URL`, tool execution is sandboxed to the container while memory persists on the server.

---

## Architecture

```
┌─────────────────────────────────────────┐
│ James's Host (Windows)                  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Letta Server (localhost:8283)  │    │
│  │ - Agent state (Opus, Sonnet)   │    │
│  │ - Memories persist here        │    │
│  └─────────────────────────────────┘    │
│            ▲                            │
│            │ http://host.docker.internal│
│            │                            │
│  ┌─────────┴───────────────────────┐    │
│  │ Docker: ellm-dev (shared)       │    │
│  │ - YOLO mode                     │    │
│  │ - C:\Git mounted at /workspace/git  │
│  │ - Tool execution sandboxed      │    │
│  │ - Opus & Sonnet both work here  │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Base image** | `debian:bookworm-slim` + Node 20 + uv + Python 3.13 + git | Slim, explicit, good package availability |
| **Host networking** | `host.docker.internal:8283` | Docker Desktop provides this on Windows; no `--network host` needed |
| **Server bind** | `0.0.0.0:8283` ✓ | Verified — container can reach it |
| **Repo storage** | Mount `C:\Git` at `/workspace/git` | Full access to repos, rest of host isolated |
| **Container count** | **One shared container** | Both agents work in same workspace; simpler |
| **Persistence** | **Persistent** (`docker start/stop`) | Avoid recloning repos each session |
| **Git credentials** | **James controls git initially** | We request, he executes; open up later |
| **Venv isolation** | uv per-project inside container | uv handles this cleanly |

**First project in container:** Get async agent comms working in LC.

---

## Draft Dockerfile

```dockerfile
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

# Install Letta Code
RUN npm install -g @letta-ai/letta-code

# Set working directory
WORKDIR /workspace

# Default to connecting to host Letta server
ENV LETTA_BASE_URL="http://host.docker.internal:8283"

# Entry point
CMD ["bash"]
```

---

## Usage

```powershell
# Build image and create container (first time, or after Dockerfile changes)
.\build.ps1

# Launch existing container
.\launch.ps1

# Inside container — Opus and Sonnet pre-pinned
letta -n Opus --yolo
# or
letta -n Sonnet --yolo

# Open additional shells into same container
docker exec -it ellm-dev bash

# Stop container
docker stop ellm-dev
```

**Filesystem access:**
- `C:\Git` mounted read-write at `/workspace/git`
- Rest of host filesystem remains isolated
- Git credentials: James controls initially, can open up later

**Pre-configured:**
- Opus and Sonnet agent IDs pinned in `letta-settings.json`
- No need to connect with full agent ID first

---

## TODO

- [x] Verify Letta server bind address (0.0.0.0 ✓)
- [x] Decide persistent vs ephemeral (persistent ✓)
- [x] Decide container count (one shared ✓)
- [x] Build and test the Dockerfile ✓
- [x] Verify LC YOLO works ✓
- [x] Verify sandbox isolation (edit from container failed correctly) ✓
- [x] Add color support (TERM + COLORTERM) ✓
- [x] Disable auto-update (DISABLE_AUTOUPDATER) ✓
- [x] Mount C:\Git for repo access ✓
- [ ] First project: async agent comms in LC
