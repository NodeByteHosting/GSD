# Installer Containers

Lightweight, temporary Docker images used by deployment scripts (Pterodactyl, custom managers) to install game servers and applications. These are **not production containers**—they're deployment utilities.

## Purpose

When deploying a new game server or application, installers:
1. **Pre-install dependencies** - `curl`, `wget`, `git`, `tar`, `jq`, etc.
2. **Reduce deployment time** - Scripts don't need to install basic tools
3. **Ensure consistency** - Same tools available across all deployments
4. **Lightweight** - Temporary containers, deleted after install completes

## Available Images

- **Alpine 3.20** - Minimal, ~11MB uncompressed
- **Debian Bookworm** - Full package support + 32-bit libraries, ~150MB uncompressed

## Usage

### With Pterodactyl Install Scripts

```bash
# Pterodactyl runs your install script inside a temporary installer container
docker run --rm -it \
  -v /path/to/server:/mnt/server \
  ghcr.io/nodebytehosting/installers:alpine \
  bash /path/to/install.sh
```

### Manual Deployment

```bash
# Alpine variant
docker run --rm -it \
  -v /path/to/game:/mnt/installer \
  ghcr.io/nodebytehosting/installers:alpine \
  /bin/sh -c "cd /mnt/installer && ./install.sh"

# Debian variant with 32-bit support
docker run --rm -it \
  -v /path/to/game:/mnt/installer \
  ghcr.io/nodebytehosting/installers:debian \
  /bin/bash -c "cd /mnt/installer && ./install.sh"
```

### Environment Variables

Pass through to the install script:

```bash
docker run --rm -it \
  -v /path/to/game:/mnt/installer \
  -e GAME_LICENSE=your_license \
  -e SERVER_PORT=30120 \
  ghcr.io/nodebytehosting/installers:alpine \
  ./install.sh
```

## Pre-installed Tools

Both Alpine and Debian installers include:

| Tool | Purpose |
|------|---------|
| `curl` | HTTP/HTTPS downloads |
| `wget` | Alternative downloader |
| `git` | Clone repositories |
| `tar` | Archive extraction |
| `jq` | JSON parsing |
| `ca-certificates` | SSL/TLS validation |

### Debian-specific

- `lib32gcc-s1` - 32-bit library support
- `libsdl2-2.0-0:i386` - 32-bit SDL2 (some older games need this)
- Full apt package repository access

## Comparison

| Aspect | Alpine | Debian |
|--------|--------|--------|
| Base size | ~11MB | ~150MB |
| Common tools | ✅ | ✅ |
| 32-bit support | Limited | ✅ Full |
| Package mgr | apk | apt |
| Best for | Most games | Legacy/complex installs |
| Deployment speed | Fastest | Slower (more tools) |

## Writing Install Scripts

### Example for Alpine

```bash
#!/bin/sh
set -e

echo "Installing Game Server..."

# Download binaries
curl -sSL https://cdn.example.com/server.tar.gz -o /tmp/server.tar.gz
tar -xzf /tmp/server.tar.gz -C /mnt/installer

# Download configs
wget https://cdn.example.com/config.zip -O /tmp/config.zip
unzip /tmp/config.zip -d /mnt/installer

# Cleanup
rm -rf /tmp/*.tar.gz /tmp/*.zip

echo "Installation complete!"
```

### Example for Debian

```bash
#!/bin/bash
set -e

echo "Installing Game Server (with 32-bit support)..."

# Check architecture support
if dpkg --print-architecture | grep -q i386; then
  echo "32-bit support available"
  apt-get install -y --no-install-recommends lib32z1
fi

# Download and extract
cd /mnt/installer
curl -sSL https://cdn.example.com/server.tar.gz | tar -xz
git clone https://github.com/example/server-configs ./configs

echo "Installation complete!"
```

## Tips

1. **Use `/mnt/installer` as working directory** - Mounted as install destination by deployment tools
2. **Handle failures gracefully** - Use `set -e` to exit on first error
3. **Clean up temporaries** - Remove download files to reduce container size during install
4. **Log everything** - Scripts should output progress for debugging
5. **Test locally first** - Run installer script manually before deploying to production

## Security Notes

- These are temporary, disposable containers
- They run with the same permissions as your host user
- Don't run untrusted install scripts in these containers
- Volume mounts expose your filesystem—verify script sources

## Building Custom Installers

If you need specialized tools, extend these images:

```dockerfile
FROM ghcr.io/nodebytehosting/installers:alpine

# Add game-specific tools
RUN apk add --no-cache lua5.4 python3

WORKDIR /mnt/installer
```

Then use your custom installer in deployment scripts.

## Integration Examples

### Pterodactyl Egg Installation Script

```bash
#!/bin/sh
set -e

# This runs inside the Alpine installer container
cd /mnt/server

curl -sSL https://api.example.com/server.tar.gz | tar -xz
git clone https://github.com/example/mods ./mods

# Create config
curl -sSL https://api.example.com/config.json -o server.json

echo "Server installation successful!"
```

### Custom Deployment Manager

```bash
#!/bin/bash

SERVER_TYPE="${1:-default}"
INSTALLER_IMAGE="ghcr.io/nodebytehosting/installers:debian"

docker run --rm -it \
  -v "${PWD}:/mnt/installer" \
  -e SERVER_TYPE="$SERVER_TYPE" \
  "$INSTALLER_IMAGE" \
  bash -c "
    echo 'Deploying $SERVER_TYPE...'
    source /mnt/installer/deploy.sh
    run_deployment
  "
```

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
