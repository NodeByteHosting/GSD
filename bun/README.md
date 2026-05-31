# Bun Runtime

Docker images for Bun applications and services. Bun is a fast, all-in-one JavaScript runtime with built-in package manager, bundler, and transpiler.

## Files

- `1.0/Dockerfile` - Bun 1.0 runtime
- `1.1/Dockerfile` - Bun 1.1 runtime
- `latest/Dockerfile` - Bun latest (floating version)
- `entrypoint.sh` - Container entrypoint with STARTUP variable support
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="bun run app.ts" \
  ghcr.io/nodebytehosting/bun:bun_1.1
```

### With Docker Compose

```yaml
version: '3.8'

services:
  bun-app:
    image: ghcr.io/nodebytehosting/bun:bun_1.1
    ports:
      - "3000:3000/tcp"
    environment:
      STARTUP: "bun run app.ts"
    volumes:
      - ./app:/home/container
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t bun:1.1 bun/1.1/
docker run -it -e STARTUP="bun run app.ts" bun:1.1
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Bun command to execute (required) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected) |
| `BUN_ENV` | - | Set to `production` for production apps |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

### Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="bun run app.ts --port {{SERVER_PORT}} --bind {{INTERNAL_IP}}"

# Output
STARTUP="bun run app.ts --port 8080 --bind 172.17.0.2"
```

## Pre-installed Tools

- `bun` - JavaScript runtime with package manager and bundler
- `curl` - HTTP/HTTPS downloads
- `git` - Clone repositories
- `make` - Build automation
- `python3` - Python support for build scripts
- `ca-certificates` - Certificate authorities
- `tzdata` - Timezone data

## Usage Examples

### Simple Bun Server

```bash
docker run -it \
  -e STARTUP="bun run app.ts" \
  -p 3000:3000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/bun:bun_1.1
```

### TypeScript with tsx/elysia

```bash
docker run -it \
  -e STARTUP="bun run src/index.ts" \
  -p 3000:3000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/bun:bun_1.1
```

### Using bun.json scripts

```bash
docker run -it \
  -e STARTUP="bun run dev" \
  ghcr.io/nodebytehosting/bun:bun_1.1
```

### Direct bun execution

```bash
docker run -it \
  -e STARTUP="bun --eval 'console.log(\"Hello from Bun\")'" \
  ghcr.io/nodebytehosting/bun:bun_1.1
```

### Multi-stage build with bundler

```dockerfile
FROM ghcr.io/nodebytehosting/bun:bun_1.1 as builder

WORKDIR /home/container
COPY . .
RUN bun install
RUN bun build ./src/index.ts --outdir ./dist

FROM ghcr.io/nodebytehosting/bun:bun_1.1

COPY --from=builder /home/container/dist /home/container/dist
COPY --from=builder /home/container/node_modules /home/container/node_modules

ENV STARTUP="bun run dist/index.js"
```

## Bun Version Information

| Version | Released | Status |
|---------|----------|--------|
| **1.0** | September 2023 | Stable |
| **1.1** | Latest | Stable |
| **latest** | Floating | Always newest |

- **Base**: Alpine (oven/bun official images)
- **Platform**: linux/amd64, linux/arm64 (multiarch)
- **Includes**: Bun runtime, npm/yarn/pnpm compatibility layer

## Bun Advantages

- **Speed** - ~4x faster than Node.js for many workloads
- **All-in-one** - Bundler, transpiler, test runner included
- **TypeScript native** - No configuration needed
- **ESM by default** - Modern JavaScript syntax out of box
- **npm compatible** - Works with existing npm packages

## Performance Tips

1. **Use `bun run` scripts** - Faster than `node --loader`
2. **Enable production mode** - Set `BUN_ENV=production`
3. **Pre-build and bundle** - Use `bun build` for optimization
4. **Leverage TypeScript** - Native support, no extra tooling
5. **Use built-in APIs** - `Bun.file()`, `Bun.serve()` are optimized

## Troubleshooting

### Application won't start
- Check `STARTUP` variable is set
- Run `bun --version` to verify Bun is available
- Check application logs for errors

### Module not found
- Ensure `bunfig.toml` is present if using custom config
- Run `bun install` to install dependencies
- Check `bun.lockb` is committed

### Performance issues
- Verify `BUN_ENV=production` is set
- Check memory availability: `free -m`
- Profile with `bun --inspect`

### TypeScript compilation errors
- Ensure TypeScript files have `.ts` extension
- Check `tsconfig.json` or `bunfig.toml` configuration
- Use `bun build` to pre-compile if needed

## Extending with Other Versions

To add support for additional Bun versions, create new directories:

```bash
mkdir -p bun/1.2 bun/1.3
```

Update each Dockerfile to use the desired Bun base:

```dockerfile
FROM oven/bun:1.2-alpine
# ... rest of Dockerfile
```

Then add versions to the GitHub Actions workflow matrix:

```yaml
matrix:
  tag:
    - "1.0"
    - "1.1"
    - "1.2"
    - "latest"
```

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Bun Docs: https://bun.sh/docs
- Bun GitHub: https://github.com/oven-sh/bun
