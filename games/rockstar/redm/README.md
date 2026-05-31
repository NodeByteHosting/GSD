# RedM Recipe

Docker recipe for running RedM (Red Dead Redemption 2 multiplayer) servers with txAdmin support. Ready for Pterodactyl panels or standalone deployment.

## Files

- `Dockerfile` - Alpine 3.20 image with RedM runtime
- `start.sh` - Startup script with txAdmin configuration
- `recipe.json` - Pterodactyl egg definition
- `entrypoint.sh` - Container entrypoint
- `server.cfg` - Server configuration template
- `.dockerignore` - Build context optimization

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e REDM_LICENSE=cfxk_your_key_here \
  -e TXHOST_TXA_PORT=40120 \
  -e TXHOST_FXS_PORT=30120 \
  -e MAX_PLAYERS=32 \
  -p 40120:40120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:redm
```

### With Docker Compose

```yaml
version: '3.8'

services:
  redm-server:
    image: ghcr.io/nodebytehosting/games:redm
    ports:
      - "40120:40120/tcp"
      - "30120:30120/udp"
    environment:
      REDM_LICENSE: cfxk_your_key_here
      TXHOST_TXA_PORT: 40120
      TXHOST_FXS_PORT: 30120
      MAX_PLAYERS: 32
      AUTO_UPDATE: 1
      TXADMIN_ENABLE: 1
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t redm:latest games/rockstar/redm/
docker run -it -e REDM_LICENSE=cfxk_your_key redm:latest
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `REDM_LICENSE` | - | RedM server license key from https://portal.cfx.re/ |
| `TXHOST_TXA_PORT` | 40120 | txAdmin web panel port |
| `TXHOST_FXS_PORT` | 30120 | RedM server game port |
| `MAX_PLAYERS` | 32 | Maximum number of player slots |
| `AUTO_UPDATE` | 0 | Set to 1 to auto-download latest RedM binaries on startup |
| `TXADMIN_ENABLE` | 1 | Enable txAdmin (set to 0 to disable) |

### Pterodactyl Integration

1. Import the `recipe.json` into your Pterodactyl panel
2. Create a new server using the RedM egg
3. Set environment variables (license key, ports, etc.)
4. Start the server

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
