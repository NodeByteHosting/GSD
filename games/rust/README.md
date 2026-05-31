# Rust Recipe

Docker recipe for running Rust multiplayer servers. Based on Pterodactyl Yolks with improvements. Includes steamcmd integration for automatic server updates and Node.js wrapper for output filtering.

## Files

- `Dockerfile` - Alpine 3.20 image with Rust server runtime and Node.js
- `entrypoint.sh` - Container entrypoint with auto-update, framework support, and startup orchestration
- `wrapper.js` - Node.js wrapper for output filtering and graceful shutdown
- `recipe.json` - Pterodactyl egg configuration
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="./RustDedicated -batchmode -nographics -logFile -" \
  -e AUTO_UPDATE=1 \
  -p 28015:28015/udp \
  -p 28016:28016/tcp \
  -p 8080:8080/tcp \
  ghcr.io/nodebytehosting/games:rust
```

### With Docker Compose

```yaml
version: '3.8'

services:
  rust-server:
    image: ghcr.io/nodebytehosting/games:rust
    ports:
      - "28015:28015/udp"
      - "28016:28016/tcp"
      - "8080:8080/tcp"
    environment:
      AUTO_UPDATE: 1
      RUST_SERVER_NAME: "NodeByte Hosting"
      RUST_SERVER_SEED: 12345
      STARTUP: "./RustDedicated -batchmode -nographics -logFile - -server.hostname 'My Server'"
      FRAMEWORK: vanillaner
    restart: unless-stopped

volumes:
  rust_data:
```

### Build Locally

```bash
docker build -t rust:latest games/rust/
docker run -it rust:latest
```\ndocker build -t rust:latest games/rust/
docker run -it \
  -e STARTUP="./RustDedicated -batchmode" \
  rust:latest
```

## Configuration

### Required Environment Variables

| Variable | Description |
|----------|-------------|
| `STARTUP` | **Required** - The server startup command (e.g., `./RustDedicated -batchmode`) |

### Server Options

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTO_UPDATE` | 1 | Automatically download latest Rust server binaries on startup (0 to disable) |
| `FRAMEWORK` | vanilla | Modding framework: `vanilla`, `oxide`, or `carbon` |
| `OXIDE` | 0 | Legacy: set to 1 to enable Oxide (use `FRAMEWORK=oxide` instead) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `INTERNAL_IP` | auto-detected | Internal container IP (auto-detected via ip rout
For Rust Server Startup Examples

Basic Vanilla Server:
```bash
STARTUP="./RustDedicated -batchmode -nographics -logFile -"
```

With Configuration:
```bash
STARTUP="./RustDedicated \\
  -batchmode \\
  -nographics \\
  -logFile - \\
  -server.port 28015 \\
  -server.queryport 28016 \\
  -server.maxplayers 50 \\
  -server.hostname 'My Rust Server' \\
  -server.seed 12345 \\
  -server.worldsize 3500"
```

## Features

### Auto-Update
Set `AUTO_UPDATE=1` (default) to automatically download the latest Rust server binaries on startup using steamcmd.

### Framework Support

#### Vanilla (Default)
```bash
FRAMEWORK=vanilla
# No modifications, pure Rust
```

#### Oxide Modding Framework
```bash
FRAMEWORK=oxide
# or legacy
OXIDE=1
```
Automatically downloads and installs uMod for Rust server modding.

#### Carbon Framework
```bash
FRAMEWORK=carbon
```
Automatically downloads and installs Carbon, a modern Rust modding framework with C# support.

### Output Filtering
The `wrapper.js` Node.js script:
- Filters duplicate "Loading Prefab Bundle" messages (reduces console spam)
- Maintains `latest.log` for persistent console output
- Handles graceful shutdown on SIGTERM/SIGINT
- Supports console input (type `quit` to stop server)

## How It Works

1. **entrypoint.sh** runs on container startup:
   - Sets `INTERNAL_IP` and `TZ` environment variables
   - Runs `steamcmd` to update server binaries (if `AUTO_UPDATE=1`)
   - Handles framework installation (Carbon/Oxide)
   - Sets `LD_LIBRARY_PATH` for library compatibility
   - Parses Pterodactyl-style variables in `STARTUP` (`{{VAR}}` → `${VAR}`)
   - Launches `wrapper.js` with the startup command

2. **wrapper.js** manages the Rust process:
   - Executes the startup command
   - Filters output to remove spam
   - Logs to `latest.log`
   - Handles shutdown signals gracefully
   - Responds to console input (`quit` command)

## Troubleshooting

### Server won't start
- Check `STARTUP` variable is set correctly
- Verify steamcmd downloads completed (check logs)
- Ensure `/home/container` has sufficient disk space (~10GB)

### High CPU during startup
- Rust loads prefab bundles on startup - this is normal
- Server should stabilize once startup completes

### Framework installation fails
- Check internet connectivity
- Verify `curl` and `unzip` are available
- Check disk space

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Rust Wiki: https://wiki.facepunch.com/rust/
