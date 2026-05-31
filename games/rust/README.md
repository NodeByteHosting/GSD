# Rust Recipe

Docker recipe for running Rust multiplayer servers. Includes steamcmd integration for automatic binary management and updates.

## Files

- `Dockerfile` - Alpine 3.20 image with Rust server runtime
- `start.sh` - Startup script with auto-update capability
- `entrypoint.sh` - Container entrypoint
- `api.js` - Node.js wrapper for RCON command execution
- `.dockerignore` - Build context optimization

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e RUST_SERVER_NAME="NodeByte Hosting" \
  -e RUST_SERVER_SEED=12345 \
  -e RUST_SERVER_WORLDSIZE=3500 \
  -e RUST_SERVER_MAXPLAYERS=50 \
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
      RUST_SERVER_WORLDSIZE: 3500
      RUST_SERVER_MAXPLAYERS: 50
      RUST_SERVER_TICKRATE: 30
    volumes:
      - rust_data:/home/container
    restart: unless-stopped

volumes:
  rust_data:
```

### Build Locally

```bash
docker build -t rust:latest games/rust/
docker run -it rust:latest
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTO_UPDATE` | 1 | Automatically download latest Rust server binaries on startup |
| `RUST_SERVER_NAME` | Rust Server | Server name displayed in server browser |
| `RUST_SERVER_DESCRIPTION` | - | Server description |
| `RUST_SERVER_URL` | - | Server website URL |
| `RUST_SERVER_HEADERIMAGE` | - | Server header image URL |
| `RUST_SERVER_SEED` | Random | World seed (for deterministic world generation) |
| `RUST_SERVER_WORLDSIZE` | 3500 | World size in meters (3500 = standard size) |
| `RUST_SERVER_MAXPLAYERS` | 100 | Maximum player slots |
| `RUST_SERVER_TICKRATE` | 30 | Server tick rate (higher = more responsive, more CPU) |
| `RUST_SERVER_SAVEINTERVAL` | 300 | Auto-save interval in seconds |
| `RUST_SERVER_WIPE_SAVE` | 0 | Wipe save data on startup (set to 1 to wipe) |

### Advanced Setup

For more complex configurations (plugins, mods, RCON), mount a volume at `/home/container` and customize:

```bash
docker run -it \
  -v /path/to/rust/data:/home/container \
  -e AUTO_UPDATE=1 \
  ghcr.io/nodebytehosting/games:rust
```

## RCON Access

The `api.js` file provides Node.js-based command execution via RCON protocol. Check server logs for RCON details.

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Rust Wiki: https://wiki.facepunch.com/rust/
