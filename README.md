# ellm-sandbox

Sandboxed Docker environment for running Letta Code in YOLO mode.

## Quick Start

```powershell
# Build the image
docker build -t ellm-dev .

# First run: create persistent container
docker run -it --name ellm-dev ellm-dev

# Inside container
letta -n Opus --yolo
# or
letta -n Sonnet --yolo

# Later: restart same container
docker start -ai ellm-dev
```

## How It Works

- **Agent brain** (memory, state) lives on your Letta server
- **Tool execution** (Bash, Read, Write) runs inside the container
- Result: YOLO mode without risk to your host filesystem

See [How2Yolo.md](How2Yolo.md) for full design details.
