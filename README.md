# ellm-sandbox

Sandboxed Docker environment for running Letta Code in YOLO mode.

## DISCLAIMER
No guarentees are made about the quality of the sandboxing! I am new to docker and so I am not 100% confident in the isolation! Use at your own risk!

## Quick Start

```powershell
# Build the image (first time only)
docker build -t ellm-dev .

# Launch (creates or starts container with C:\Git mounted)
.\launch.ps1

# Inside container (Opus and Sonnet pre-pinned)
letta -n Opus --yolo
# or
letta -n Sonnet --yolo

# Open additional shells into same container
docker exec -it ellm-dev bash

# Later: restart same container
docker start -ai ellm-dev
```

## How It Works

- **Agent brain** (memory, state) lives on your Letta server
- **Tool execution** (Bash, Read, Write) runs inside the container
- **C:\Git** is mounted at `/workspace/git` — full read/write access to repos
- Rest of host filesystem remains isolated (no `rm -rf jamesBabyPictures`)

See [How2Yolo.md](How2Yolo.md) for full design details.
