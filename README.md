# NodeByte Recipes

Docker container recipes for game servers, runtimes, and applications. Works with Pterodactyl panels, custom game server managers, and standard Docker.

## Overview

NodeByte Recipes provides Alpine-based Docker images for:
- Game Servers: FiveM, RedM, Minecraft, and more
- Runtimes: Go, Node.js, Python, Bun, Java
- Multi-platform: linux/amd64 and linux/arm64

All images are automatically built and published to [GitHub Container Registry](https://github.com/orgs/NodeByteHosting/packages?repo_name=game-recipes).

## Structure

```
game-recipes/
  games/          - Game server recipes
  oses/           - OS base images (Alpine, Debian, Ubuntu)
  installers/     - Temporary installer images
  golang/         - Go runtime (1.14+)
  nodejs/         - Node.js runtime (20, 22 LTS only)
  bun/            - Bun runtime (1.0, 1.1, latest, canary)
  python/         - Python runtime (3.7-3.11)
  java/           - Java runtime (8, 11, 16, 17, 19, 21, 22, 25, 26)
```

## Available Recipes

### Game Servers

| Game | Image | Status |
|------|-------|--------|
| FiveM (GTA V) | `ghcr.io/nodebytehosting/games:fivem` | Production |
| RedM (RDR 2) | `ghcr.io/nodebytehosting/games:redm` | Coming soon |
| Minecraft | `ghcr.io/nodebytehosting/games:minecraft` | Beta |
| Rust | `ghcr.io/nodebytehosting/games:rust` | Production |
| Hytale | `ghcr.io/nodebytehosting/games:hytale` | Production |

### Runtimes

| Runtime | Versions | Image Format |
|---------|----------|--------------|
| Go | 1.14+ | `ghcr.io/nodebytehosting/golang:golang_{version}` |
| Node.js | 20, 22 (LTS only) | `ghcr.io/nodebytehosting/nodejs:nodejs_{version}` |
| Bun | 1.0, 1.1, latest, canary | `ghcr.io/nodebytehosting/bun:bun_{version}` |
| Python | 3.7, 3.8, 3.9, 3.10, 3.11 | `ghcr.io/nodebytehosting/python:python_{version}` |
| Java | 8, 8j9, 11, 11j9, 16, 16j9, 17, 19, 21, 22, 25, 26 | `ghcr.io/nodebytehosting/java:java_{version}` |

### Operating Systems & Installers

| Type | Variants | Image Format | Use Case |
|------|----------|--------------|----------|
| OS Images | Alpine 3.20, Debian Bookworm, Ubuntu 22.04-26.04 | `ghcr.io/nodebytehosting/oses:{name}` | Base container images |
| Installers | Alpine, Debian, Ubuntu, Java (8, 11, 17, 21, 25, 26) | `ghcr.io/nodebytehosting/installers:{name}` | Temporary deployment images |

## Features

- Multi-platform builds: amd64 and arm64
- Minimal: Alpine 3.20 (~3.6MB)
- Health checks and proper signal handling
- Automated builds on push, schedule, and releases
- Pterodactyl egg definitions included
- Configured via environment variables
- Non-root containers with security in mind

## Quick Start

### Pterodactyl

1. Go to Admin > Nests in your panel
2. Import the recipe JSON:
   ```
   https://raw.githubusercontent.com/NodeByteHosting/game-recipes/main/games/rockstar/fivem/recipe.json
   ```
3. Create a server using the new egg
4. Set environment variables and start

### Docker

```bash
docker pull ghcr.io/nodebytehosting/games:fivem

docker run \
  -e FIVEM_LICENSE=your_license_key \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:fivem
```

### Docker Compose

```yaml
version: '3.8'

services:
  fivem-server:
    image: ghcr.io/nodebytehosting/games:fivem
    ports:
      - "30120:30120/udp"
      - "40120:40120"
    environment:
      FIVEM_LICENSE: your_license_key
      MAX_PLAYERS: 128
      TXADMIN_ENABLE: 1
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "test", "-f", "/proc/1/cmdline"]
      interval: 30s
      timeout: 5s
      retries: 3
```

## Image Tags

Images are tagged automatically based on branch/release:

### Main Branch
- `ghcr.io/nodebytehosting/games:fivem` - Latest production
- `ghcr.io/nodebytehosting/games:latest` - Latest across all games

### Develop Branch
- `ghcr.io/nodebytehosting/games:fivem-dev` - Development version

### Release Tags
- `ghcr.io/nodebytehosting/games:fivem-v1.0.0` - Semantic versioning

## Building Locally

```bash
# Clone repository
git clone https://github.com/NodeByteHosting/game-recipes.git
cd game-recipes

# Build a specific recipe
docker build -f games/rockstar/fivem/Dockerfile -t my-fivem:latest games/rockstar/fivem

# Push to registry
docker tag my-fivem:latest ghcr.io/nodebytehosting/games:fivem
docker push ghcr.io/nodebytehosting/games:fivem
```

## CI/CD

Recipes build automatically via GitHub Actions:

- `games.yml` - Game server recipes
- `go.yml` - Go runtimes
- `nodejs.yml` - Node.js runtimes
- `bun.yml` - Bun runtimes
- `python.yml` - Python runtime
- `java.yml` - Java runtime
- `oses.yml` - Base OS images
- `installers.yml` - Installer utilities

Builds trigger on:
- Manual dispatch
- Schedule (1st of month)
- Push to main/develop
- GitHub releases

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Adding new game recipes
- Adding new runtime versions
- Code standards and best practices
- Testing guidelines

## Code of Conduct

Please review our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - we welcome all contributors and maintain an inclusive community.

## Security

See [SECURITY.md](SECURITY.md) for:
- Reporting security vulnerabilities
- Security best practices
- Dependency scanning

## License

MIT - See LICENSE for details. Free for personal and commercial use.

## Support

- Documentation: Each recipe has a README with options
- Issues: [GitHub Issues](https://github.com/NodeByteHosting/game-recipes/issues)
- Discussions: [GitHub Discussions](https://github.com/NodeByteHosting/game-recipes/discussions)
- Discord: [Join our server](https://discord.gg/Bg3Sf5fqa4)

## Credits

Built and maintained by [NodeByte LTD](https://nodebyte.co.uk)

## Image Tags

| Branch | Tags | Purpose |
|--------|------|----------|
| main | game + latest | Production |
| develop | game-dev | Testing |
| releases | game-vX.Y.Z | Versioned |
| commits | game-sha | Debugging |

## FAQ

**Build not working?**
Check the Actions tab for error logs. Make sure the Dockerfile exists and is valid.

**Recipe not loading in Pterodactyl?**
Verify the image name matches in recipe.json. Check the image exists on ghcr.io.

**Variables not set?**
Check start.sh exports the variable. Make sure recipe.json defines it. Verify Pterodactyl passes it to the container.
