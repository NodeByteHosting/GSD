# Game Server Recipes

Docker recipes for deploying game servers. All recipes are built on Alpine 3.20 base images with minimal footprint while maintaining full functionality.

## Quick Reference

| Game | Publisher | Status | Image | Auto-Update | Mods/Plugins |
|------|-----------|--------|-------|------------|-------------|
| [FiveM](#fivem-gta-v) | Rockstar GTA V | Production | `ghcr.io/nodebytehosting/games:fivem` | ✓ | ✓ CFX.re |
| [RedM](#redm-rdr-2) | Rockstar RDR 2 | Coming Soon | `ghcr.io/nodebytehosting/games:redm` | ✓ | ✓ CFX.re |
| [Rust](#rust) | Facepunch | Production | `ghcr.io/nodebytehosting/games:rust` | ✓ | ✓ Oxide/Carbon |
| [Hytale](#hytale) | Hypixel | Production | `ghcr.io/nodebytehosting/games:hytale` | - | ✓ Plugins |
| [Minecraft](#minecraft) | Microsoft | Beta | `ghcr.io/nodebytehosting/games:minecraft` | - | ✓ Plugins/Mods |

## Directory Structure

```
games/
├── README.md                    # This file
├── fivem/                       # GTA V multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── recipe.json
│   └── README.md
├── redm/                        # Red Dead Redemption 2 multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── recipe.json
│   └── README.md
├── rust/                        # Rust multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── wrapper.js
│   ├── recipe.json
│   └── README.md
├── hytale/                      # Hytale multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── recipe.json
│   └── README.md
├── minecraft/                   # Minecraft multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── recipe.json
│   └── README.md
└── rockstar/                    # Rockstar game servers
    ├── fivem/                   # FiveM (GTA V)
    └── redm/                    # RedM (RDR 2)
```

## Game Recipes

### FiveM (GTA V)

A multiplayer modification framework for Grand Theft Auto V. Includes automatic resource downloading and server management.

```bash
docker run -it \
  -e STARTUP="./FXServer.sh" \
  -e AUTHORITATIVE=1 \
  -e MAXPLAYERS=32 \
  -p 30120:30120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:fivem
```

**Features:**
- Automatic FXServer binary updates
- CFX.re resource support
- Admin management system
- Built-in economy system
- Multi-platform support (Linux/Windows)

**See:** [FiveM Recipe](./rockstar/fivem/README.md)

---

### RedM (RDR 2)

A multiplayer modification framework for Red Dead Redemption 2. Similar to FiveM with RDR2-specific optimizations.

```bash
docker run -it \
  -e STARTUP="./FXServer.sh" \
  -e AUTHORITATIVE=1 \
  -p 30120:30120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:redm
```

**Features:**
- Automatic FXServer binary updates
- CFX.re resource support
- Wild West gameplay framework
- Admin and whitelist management

**See:** [RedM Recipe](./rockstar/redm/README.md)

---

### Rust

A multiplayer survival game with modding support via Oxide and Carbon frameworks.

```bash
docker run -it \
  -e STARTUP="./RustDedicated -batchmode -nographics -logFile -" \
  -e AUTO_UPDATE=1 \
  -e FRAMEWORK=vanilla \
  -p 28015:28015/udp \
  -p 28016:28016/tcp \
  ghcr.io/nodebytehosting/games:rust
```

**Features:**
- Automatic server binary updates via steamcmd
- Modding framework support (Vanilla/Oxide/Carbon)
- Output filtering (console spam reduction)
- Process management via Node.js wrapper
- LD_LIBRARY_PATH compatibility

**See:** [Rust Recipe](./rust/README.md)

---

### Hytale

A voxel sandbox MMO with extensive modding support and procedural generation.

```bash
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  -e INSTALL_SOURCEQUERY_PLUGIN=0 \
  -p 8515:8515/tcp \
  -p 8516:8516/tcp \
  ghcr.io/nodebytehosting/games:hytale
```

**Features:**
- Java 25 JRE runtime
- Plugin auto-installation support (hytale-sourcequery)
- Config.json customization
- Memory scaling recommendations
- Server binary mounting support

**See:** [Hytale Recipe](./hytale/README.md)

---

### Minecraft

A sandbox MMO with various server software options (Vanilla, Spigot, Paper, etc.).

```bash
docker run -it \
  -e STARTUP="java -Xmx1024M -jar server.jar nogui" \
  -p 25565:25565/tcp \
  ghcr.io/nodebytehosting/games:minecraft
```

**Features:**
- Multi-server-software support
- Plugin ecosystem
- World management
- Modpack deployment
- Memory scaling options

**See:** [Minecraft Recipe](./minecraft/README.md)

---

## Common Features

All game server recipes include:

- **Alpine 3.20 Base** - Minimal (~3.6MB) yet feature-complete
- **Health Checks** - Automatic container health monitoring
- **Proper Signal Handling** - Graceful shutdown on SIGTERM/SIGINT
- **Environment Variables** - Pterodactyl-compatible variable substitution
- **Timezone Support** - Configurable TZ variable
- **Logging** - Persistent console output and log files
- **Multi-platform** - Builds for amd64 and arm64

## Building Locally

### Build a single game server

```bash
docker build -t my-rust:latest games/rust/
```

### Build and tag for registry

```bash
docker build -t ghcr.io/nodebytehosting/games:rust games/rust/
docker push ghcr.io/nodebytehosting/games:rust
```

### Build with custom build args

```bash
docker build \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t my-game:latest \
  games/[game]/
```

## Configuration

Each recipe uses environment variables for configuration. Common variables:

| Variable | Scope | Description |
|----------|-------|-------------|
| `STARTUP` | All | Server startup command (required) |
| `TZ` | All | Timezone (default: UTC) |
| `INTERNAL_IP` | All | Container IP (auto-detected) |
| `AUTO_UPDATE` | Rust, FiveM, RedM | Auto-update binaries on startup |
| `FRAMEWORK` | Rust | Modding framework: vanilla, oxide, carbon |
| `MAXPLAYERS` | FiveM, RedM | Maximum player slots |
| `AUTHORITATIVE` | FiveM, RedM | Authoritative mode (1/0) |

See individual recipe READMEs for complete configuration options.

## Pterodactyl Integration

All recipes support Pterodactyl's variable substitution syntax:

```bash
# In STARTUP variable
STARTUP="./RustDedicated -server.port {{SERVER_PORT}} -server.maxplayers {{MAX_PLAYERS}}"

# Translates to:
./RustDedicated -server.port 28015 -server.maxplayers 50
```

Available Pterodactyl variables:
- `{{SERVER_PORT}}` - Primary server port
- `{{MAX_PLAYERS}}` - Maximum player count
- `{{MEMORY}}` - Available memory (MB)
- Any custom environment variable via `{{VARIABLE_NAME}}`

## Memory Recommendations

| Game | Min | Recommended | High Load |
|------|-----|-------------|-----------|
| Rust (10-50 players) | 2GB | 4GB | 6GB+ |
| Rust (50-100 players) | 4GB | 6GB | 8GB+ |
| FiveM (50 players) | 2GB | 4GB | 6GB |
| RedM (50 players) | 2GB | 4GB | 6GB |
| Hytale (1-50 players) | 1GB | 2-4GB | 6GB+ |
| Minecraft (20-50 players) | 1GB | 2-3GB | 4GB+ |

## Image Tagging Strategy

All game recipes follow consistent tagging:

- `ghcr.io/nodebytehosting/games:rust` - Latest stable
- `ghcr.io/nodebytehosting/games:rust-dev` - Development branch
- `ghcr.io/nodebytehosting/games:rust-v1.0.0` - Semantic version release
- `ghcr.io/nodebytehosting/games:latest` - Latest across all games

## Troubleshooting

### Container exits immediately
- Check `STARTUP` variable is set
- Verify all dependencies are installed
- Check logs: `docker logs <container-id>`

### High memory usage
- Reduce JVM `-Xmx` setting (Java-based games)
- Check for memory leaks in plugins/mods
- Monitor with: `docker stats`

### Port conflicts
- Ensure ports aren't in use: `netstat -tlnp | grep :PORT`
- Map to different host port: `-p 8080:28015`

### Network issues
- Verify port forwarding on router/firewall
- Check internal IP: `docker inspect <container-id>`
- Test connectivity: `curl <container-ip>:<port>`

### Plugin/mod installation fails
- Check internet connectivity in container
- Verify download URLs are accessible
- Check disk space: `docker exec <container-id> df -h`

## Contributing

To add a new game server recipe:

1. Create `games/[publisher]/[game]/` directory
2. Add `Dockerfile` (Alpine 3.20 base, follows standards)
3. Add `entrypoint.sh` (handles startup, variables, logging)
4. Add `README.md` (documentation)
5. Add `recipe.json` (Pterodactyl config, optional)
6. Update `.github/workflows/games.yml` matrix
7. Update main `README.md` games table

See [Rust Recipe](./rust/) as a reference implementation.

## Related Documentation

- [Docker Compose Guide](https://docs.docker.com/compose/)
- [Pterodactyl Panel Docs](https://pterodactyl.io/panel/index.html)
- [Alpine Linux Package Index](https://pkgs.alpinelinux.org/)
- [Game-specific Documentation](#game-recipes)

## License

MIT License - See [LICENSE](../../LICENSE) for details.
