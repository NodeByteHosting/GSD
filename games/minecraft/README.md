# Minecraft Recipe

Docker recipe for running Minecraft Java Edition servers. Supports multiple Java versions (8, 11, 17, 21) for compatibility with different server software versions.

## Files

- `Dockerfile` - Alpine 3.20 image with multiple Java versions
- `start.sh` - Startup script with server configuration
- `entrypoint.sh` - Container entrypoint
- `.dockerignore` - Build context optimization

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e JAVA_VERSION=17 \
  -e MEMORY=2048 \
  -e EULA=TRUE \
  -p 25565:25565/tcp \
  ghcr.io/nodebytehosting/games:minecraft
```

### With Docker Compose

```yaml
version: '3.8'

services:
  minecraft-server:
    image: ghcr.io/nodebytehosting/games:minecraft
    ports:
      - "25565:25565/tcp"
    environment:
      JAVA_VERSION: 17
      MEMORY: 2048
      EULA: "TRUE"
      SERVER_NAME: "NodeByte Hosting"
      DIFFICULTY: 2
      GAMEMODE: survival
      MAX_PLAYERS: 20
      ONLINE_MODE: "true"
    volumes:
      - minecraft_data:/home/container
    restart: unless-stopped

volumes:
  minecraft_data:
```

### Build Locally

```bash
docker build -t minecraft:latest games/minecraft/
docker run -it -e JAVA_VERSION=17 -e EULA=TRUE minecraft:latest
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_VERSION` | 17 | Java version: 8, 11, 17, or 21 |
| `MEMORY` | 1024 | Memory allocation in MB |
| `EULA` | FALSE | Accept Minecraft EULA (set to TRUE to start server) |
| `SERVER_NAME` | Minecraft Server | Server name displayed in server list |
| `DIFFICULTY` | 2 | Difficulty level: 0 (peaceful), 1 (easy), 2 (normal), 3 (hard) |
| `GAMEMODE` | survival | Game mode: survival, creative, adventure, spectator |
| `MAX_PLAYERS` | 20 | Maximum number of players |
| `ONLINE_MODE` | true | Require players to authenticate with Minecraft account |
| `VIEW_DISTANCE` | 10 | Render distance in chunks |
| `LEVEL_SEED` | - | Seed for world generation |

### Server Configuration

The `server.properties` file is generated automatically with defaults. To customize, mount a volume and edit the file before startup, or set environment variables above.

## Supported Server Software

This image works with any Java-based Minecraft server:
- Vanilla (original Minecraft server)
- Paper/Spigot (performance improvements)
- Fabric (lightweight modding)
- Quilt (modern modding)
- Forge (traditional modding)

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
