# FiveM Recipe

A Docker recipe for running FiveM servers with txAdmin, ready for Pterodactyl panels or standalone deployment.

## Files

- `Dockerfile` - Alpine-based image with FiveM runtime
- `start.sh` - Startup script with txAdmin configuration
- `recipe.json` - Pterodactyl egg definition
- `entrypoint.sh` - Container entrypoint

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e FIVEM_LICENSE=cfxk_your_key_here \
  -e TXADMIN_PORT=40120 \
  -e SERVER_PORT=30120 \
  -e MAX_PLAYERS=32 \
  -p 40120:40120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:fivem
```

### Build Locally

```bash
docker build -t fivem:latest rockstar/fivem/
docker run -it \
  -e FIVEM_LICENSE=cfxk_your_key_here \
  -p 40120:40120/tcp \
  -p 30120:30120/udp \
  fivem:latest
```

### Pterodactyl

1. Import `recipe.json` as an egg
2. Create server with this egg
3. Set environment variables in the panel:
   - `FIVEM_LICENSE` - Server key from https://portal.cfx.re/
   - `MAX_PLAYERS` - Player limit (default: 32)
   - `AUTO_UPDATE` - Set to `1` for auto-updates (default: 0)

## Configuration

All via environment variables:

| Variable | Default | Notes |
|----------|---------|-------|
| `FIVEM_LICENSE` | - | Required: server key from portal.cfx.re |
| `TXADMIN_PORT` | 40120 | txAdmin web panel |
| `SERVER_PORT` | 30120 | FiveM server port |
| `MAX_PLAYERS` | 32 | Player limit |
| `AUTO_UPDATE` | 0 | Set to `1` to auto-download on startup |
| `TXADMIN_ENABLE` | 1 | Set to `0` to skip txAdmin |
| `PROVIDER_NAME` | NodeByte Hosting | Your provider name |
| `PROVIDER_LOGO` | - | Logo URL for txAdmin login |

## Notes

- First startup with `AUTO_UPDATE=1` takes 2-5 minutes
- FiveM binaries download to `/home/container/alpine/`
- txAdmin data stored in `/home/container/txData/`
- License key is required for server to run
