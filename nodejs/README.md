# Node.js Runtime

Docker images for Node.js applications and services. Includes npm, common development tools, and multimedia libraries.

## Files

- `20/Dockerfile` - Node.js 20 LTS with development tools
- `22/Dockerfile` - Node.js 22 LTS with development tools
- `entrypoint.sh` - Container entrypoint with STARTUP variable support
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="npm start" \
  ghcr.io/nodebytehosting/nodejs:nodejs_20
```

### With Docker Compose

```yaml
version: '3.8'

services:
  node-app:
    image: ghcr.io/nodebytehosting/nodejs:nodejs_20
    ports:
      - "3000:3000/tcp"
    environment:
      STARTUP: "npm start"
      NODE_ENV: production
    volumes:
      - ./app:/home/container
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t node:20 nodejs/20/
docker run -it -e STARTUP="npm start" node:20
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Node.js command to execute (required) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected) |
| `NODE_ENV` | - | Set to `production` for production apps |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

### Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="node app.js --port {{SERVER_PORT}} --bind {{INTERNAL_IP}}"

# Output
STARTUP="node app.js --port 8080 --bind 172.17.0.2"
```

## Pre-installed Tools

- `npm` - Node package manager
- `curl` - HTTP/HTTPS downloads
- `wget` - Alternative downloader
- `git` - Clone repositories
- `openssl` - SSL/TLS utilities
- `ffmpeg` - Audio/video processing
- `sqlite` - Database support
- `tar` - Archive extraction
- `ca-certificates` - Certificate authorities
- `tzdata` - Timezone data

## Usage Examples

### Express.js Application

```bash
docker run -it \
  -e STARTUP="npm start" \
  -e NODE_ENV=production \
  -p 3000:3000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/nodejs:nodejs_20
```

### npm Scripts with Arguments

```bash
docker run -it \
  -e STARTUP="npm run dev -- --port 8080" \
  ghcr.io/nodebytehosting/nodejs:nodejs_20
```

### Direct Node Execution

```bash
docker run -it \
  -e STARTUP="node --max-old-space-size=2048 app.js" \
  ghcr.io/nodebytehosting/nodejs:nodejs_20
```

### TypeScript with ts-node

```bash
docker run -it \
  -e STARTUP="npx ts-node src/index.ts" \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/nodejs:nodejs_20
```

## Node.js Version Information

| Version | LTS Period | Status |
|---------|-----------|--------|
| **20** | Oct 2023 - Apr 2026 | Active (EOL approaching) |
| **22** | Oct 2024 - Oct 2027 | Active (Recommended) |

- **npm** - Latest version for each Node.js release
- **Base**: Alpine 3.20 via official `node` images
- **Platform**: linux/amd64, linux/arm64 (multiarch)

## Extending with Other Versions

To add support for additional Node.js versions, create new directories:

```bash
mkdir -p nodejs/24 nodejs/26
```

Update each Dockerfile to use the desired Node.js base:

```dockerfile
FROM node:24-alpine3.20
# ... rest of Dockerfile
```

Then add versions to the GitHub Actions workflow matrix in `.github/workflows/nodejs.yml`:

```yaml
matrix:
  version:
    - "20"
    - "22"
    - "24"
```

**Note:** We only support active LTS versions. EOL versions (18, 16, 14, 12) are not supported.

## Performance Tips

1. **Use `NODE_ENV=production`** - Disables development dependencies
2. **Set memory limits** - Use `--max-old-space-size` for consistent performance
3. **Enable clustering** - Use Node cluster module for multi-core systems
4. **Use npm ci** - Faster, more reliable than `npm install` in containers
5. **Minimize node_modules** - Use `npm prune --production` to remove dev dependencies

## Native Module Support

The container includes build tools for native modules:

```dockerfile
RUN npm install --build-from-source
```

Pre-installed: `python3`, `make`, `g++` (for node-gyp compilation)

## Troubleshooting

### Application won't start
- Check `STARTUP` variable is set
- Run `npm list` to verify dependencies
- Check application logs for errors

### Port already in use
- Verify port binding in application
- Check container port mapping: `docker port <container>`

### Out of memory
- Increase container memory: `docker run -m 2g`
- Use `--max-old-space-size` flag in Node
- Monitor with `ps aux` and `free -m`

### Module not found
- Ensure `node_modules` is installed
- Check `package-lock.json` or `yarn.lock`
- Run `npm ci` or `npm install` in Dockerfile

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Node.js Docs: https://nodejs.org/en/docs/
