# Alpine 3.20 Base Image

Lightweight Alpine Linux 3.20 base image with Pterodactyl compatibility. Designed as a foundation for game servers and runtime containers.

## Files

- `Dockerfile` - Alpine 3.20 image with container user, timezone support, health checks
- `entrypoint.sh` - Pterodactyl-compatible entrypoint with variable substitution
- `README.md` - This file

## Features

- **Minimal footprint** - Alpine Linux 3.20 (~3.6MB base)
- **Pterodactyl ready** - Supports `{{VAR}}` → `${VAR}` substitution for panel integration
- **Signal handling** - Proper ENTRYPOINT/exec usage for container signal propagation
- **Health checks** - Built-in process validation via `/proc/1/cmdline`
- **Non-root user** - Runs as `container:container` user for security
- **Timezone support** - Configurable via `TZ` environment variable (default: UTC)
- **OCI compliant** - Includes standard image labels (source, description, license, version)

## Quick Start

### Basic Usage

```dockerfile
FROM ghcr.io/nodebytehosting/oses:alpine

RUN apk add --no-cache \
    your-app \
    dependencies

COPY ./app /home/container/app
COPY ./start.sh /home/container/start.sh

CMD ["/bin/bash", "/home/container/start.sh"]
```

### Docker Run

```bash
docker run -it \
  -e STARTUP="bash /home/container/start.sh" \
  ghcr.io/nodebytehosting/oses:alpine
```

### With Pterodactyl

The base image automatically handles variable interpolation. In Pterodactyl:

1. Set `STARTUP` to: `bash /home/container/start.sh --port {{SERVER_PORT}} --name "{{SERVER_NAME}}"`
2. The entrypoint converts this to: `bash /home/container/start.sh --port 30120 --name "My Server"`
3. Your script receives the interpolated values

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Command to execute (supports {{VAR}} substitution) |
| `TZ` | UTC | Timezone (e.g., America/New_York, Europe/London) |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected, exported for scripts) |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

## Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="./server --port {{SERVER_PORT}} --name {{SERVER_NAME}}"

# Output
./server --port 30120 --name "My Cool Server"
```

Variables are replaced from the environment before execution. This allows Pterodactyl panels to dynamically configure servers without modifying scripts.

## Building Custom Images

### Example: Minecraft Server

```dockerfile
FROM ghcr.io/nodebytehosting/oses:alpine

RUN apk add --no-cache \
    openjdk17-jre \
    curl \
    wget

COPY ./entrypoint.sh /home/container/entrypoint.sh
COPY ./start.sh /home/container/start.sh

RUN chmod +x /home/container/*.sh

EXPOSE 25565/tcp

ENTRYPOINT ["/home/container/entrypoint.sh"]
CMD ["bash", "/home/container/start.sh"]
```

### Example: Go Runtime

```dockerfile
FROM ghcr.io/nodebytehosting/oses:alpine

RUN apk add --no-cache \
    ca-certificates \
    git \
    go \
    make

WORKDIR /home/container
COPY ./app /home/container/app

ENTRYPOINT ["/home/container/entrypoint.sh"]
```

## Signal Handling

The image uses `ENTRYPOINT` with `exec` to ensure signals are properly propagated to your application:

- `SIGTERM` → Container stop requested
- `SIGINT` → Keyboard interrupt (Ctrl+C)
- `SIGKILL` → Force kill (cannot be caught)

Your startup script should handle these gracefully for clean shutdowns.

## Health Checks

Built-in health check validates the process is running:

```bash
test -f /proc/1/cmdline || exit 1
```

- Interval: 30s
- Timeout: 5s
- Start period: 30s
- Retries: 3 failures = unhealthy

Override in your Dockerfile if needed:

```dockerfile
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD curl -f http://localhost:8080/health || exit 1
```

## Customizing the Entrypoint

If you need custom startup logic before executing STARTUP:

```bash
#!/bin/bash
set -e

# Your custom setup
echo "Initializing server..."
mkdir -p /home/container/data

# Pass control to Pterodactyl startup
export STARTUP="bash /home/container/start.sh"
exec /entrypoint.sh
```

Then in your Dockerfile:

```dockerfile
COPY ./custom-entrypoint.sh /home/container/custom-entrypoint.sh
ENTRYPOINT ["/home/container/custom-entrypoint.sh"]
```

## Best Practices

1. **Keep images small** - Use Alpine's apk instead of apt; only install what's needed
2. **Use `exec`** - Always exec your final process for signal handling
3. **Set STARTUP** - Define this environment variable or CMD for Pterodactyl compatibility
4. **Use non-root** - Don't override the `container` user unless necessary
5. **Log to stdout** - Write logs to stdout/stderr for Docker log aggregation
6. **Health checks** - Implement meaningful health checks for orchestration

## Performance Notes

- Alpine 3.20 base: ~3.6MB compressed, ~11MB uncompressed
- Multi-platform support: linux/amd64 and linux/arm64 via QEMU
- Fast startup: No unnecessary dependencies or services

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Alpine Docs: https://wiki.alpinelinux.org/
