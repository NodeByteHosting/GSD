# Debian Bookworm Base Image

Production-ready Debian Linux Bookworm base image with Pterodactyl compatibility. Suitable for applications requiring larger standard library or package availability compared to Alpine.

## Files

- `Dockerfile` - Debian Bookworm slim image with container user, timezone support, health checks
- `entrypoint.sh` - Pterodactyl-compatible entrypoint with variable substitution
- `README.md` - This file

## Features

- **Current & supported** - Debian Bookworm (current stable, supported until June 2026)
- **Minimal footprint** - Uses `bookworm-slim` variant (~60MB base, much smaller than full Debian)
- **Pterodactyl ready** - Supports `{{VAR}}` → `${VAR}` substitution for panel integration
- **Signal handling** - Proper ENTRYPOINT/exec usage for container signal propagation
- **Health checks** - Built-in process validation via `/proc/1/cmdline`
- **Non-root user** - Runs as `container:container` user for security
- **Timezone support** - Configurable via `TZ` environment variable (default: UTC)
- **OCI compliant** - Includes standard image labels (source, description, license, version)
- **APT package manager** - Access to Debian stable repository (~50k+ packages)

## Quick Start

### Basic Usage

```dockerfile
FROM ghcr.io/nodebytehosting/oses:debian

RUN apt-get update && apt-get install -y --no-install-recommends \
    your-app \
    dependencies \
    && rm -rf /var/lib/apt/lists/*

COPY ./app /home/container/app
COPY ./start.sh /home/container/start.sh

CMD ["/bin/bash", "/home/container/start.sh"]
```

### Docker Run

```bash
docker run -it \
  -e STARTUP="bash /home/container/start.sh" \
  ghcr.io/nodebytehosting/oses:debian
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
| `DEBIAN_FRONTEND` | noninteractive | Debian package manager mode (non-interactive) |
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

### Example: Application Server

```dockerfile
FROM ghcr.io/nodebytehosting/oses:debian

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libssl-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./app /home/container/app
RUN chmod +x /home/container/app/start.sh

EXPOSE 8080/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash", "/home/container/app/start.sh"]
```

### Example: Development Environment

```dockerfile
FROM ghcr.io/nodebytehosting/oses:debian

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    gdb \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/container
ENTRYPOINT ["/entrypoint.sh"]
```

## Alpine vs Debian

| Aspect | Alpine | Debian |
|--------|--------|--------|
| Base size | ~3.6MB | ~60MB |
| Package count | Limited | 50,000+ |
| Package manager | apk | apt/dpkg |
| C library | musl | glibc |
| Build tools | Minimal | Comprehensive |
| Use case | Game servers | Complex apps |
| Learning curve | Steeper | Easier |

**Choose Debian if:**
- You need common development tools (gcc, make, cmake)
- Your application uses glibc-specific features
- You want maximum package availability
- You're building development/testing images

**Choose Alpine if:**
- You need minimal image size
- Image size is critical (bandwidth, storage)
- You're building game servers
- You want faster container startup

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

## Package Installation Best Practices

Always use these patterns to minimize layer size:

```dockerfile
# Good: Clean up after install
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Bad: Leaves package manager cache
RUN apt-get update && apt-get install -y curl git
```

Use `--no-install-recommends` to skip optional dependencies:

```dockerfile
# Installs only essential dependencies
RUN apt-get install -y --no-install-recommends python3

# Also installs optional packages like dev tools
RUN apt-get install -y python3
```

## Customizing the Entrypoint

If you need custom startup logic before executing STARTUP:

```bash
#!/bin/bash
set -e

# Your custom setup
echo "Initializing application..."
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

## Version Information

- **Base**: Debian Bookworm (12)
- **Released**: June 2023
- **Security support**: Until June 2026
- **LTS support**: Extended to June 2028

For long-term support, consider using Debian Bookworm + applying security patches from the Debian team.

## Best Practices

1. **Use `--no-install-recommends`** - Reduces image size by 30-50%
2. **Clean apt cache** - Always `rm -rf /var/lib/apt/lists/*` after install
3. **Use `exec`** - Always exec your final process for signal handling
4. **Set STARTUP** - Define this environment variable or CMD for Pterodactyl compatibility
5. **Use non-root** - Don't override the `container` user unless necessary
6. **Log to stdout** - Write logs to stdout/stderr for Docker log aggregation
7. **Multi-stage builds** - Use for reducing final image size on complex builds
8. **Pin versions** - Pin package versions for reproducibility when needed

## Performance Notes

- Debian Bookworm slim: ~60MB compressed, ~150MB uncompressed
- Multi-platform support: linux/amd64 and linux/arm64 via QEMU
- APT caching between layers: Clean carefully to avoid bloat
- Faster package installation: Larger package count vs Alpine

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Debian Docs: https://www.debian.org/doc/
- Security: https://security.debian.org/
