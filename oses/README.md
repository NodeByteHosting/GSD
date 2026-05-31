# Operating System Recipes

Minimal base container images for deploying applications. These serve as the foundation for runtimes, installers, and custom deployments.

## Quick Reference

| OS | Size | Image | Use Case |
|----|------|-------|----------|
| [Alpine 3.20](#alpine-320) | ~3.6 MB | `ghcr.io/nodebytehosting/oses:alpine` | Production servers, microservices, lightweight apps |
| [Debian Bookworm](#debian-bookworm) | ~80 MB | `ghcr.io/nodebytehosting/oses:debian` | Full-featured, package availability, compatibility |
| [Ubuntu](#ubuntu) | ~77 MB (22.04) - ~90 MB (26.04) | `ghcr.io/nodebytehosting/oses:ubuntu_XX.XX` | Latest tools, server deployments, development |

## Directory Structure

```
oses/
├── README.md              # This file
├── alpine/                # Alpine Linux 3.20 (minimal)
│   ├── Dockerfile
│   └── README.md
└── debian/                # Debian Bookworm (full-featured)
    ├── Dockerfile
    └── README.md
```

## OS Recipes

### Alpine 3.20

Minimal Linux distribution (~3.6 MB) designed for containerized applications.

**Dockerfile:**
```dockerfile
FROM alpine:3.20
LABEL author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"
LABEL org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"

RUN apk add --no-cache ca-certificates curl
USER nobody
```

**Pull:**
```bash
docker pull ghcr.io/nodebytehosting/oses:alpine
```

**Features:**
- ✓ Minimal footprint (~3.6 MB)
- ✓ Fast startup
- ✓ Low resource usage
- ✓ ~11,000 packages available
- ✓ musl libc (C standard library)
- ✓ apk package manager
- ✓ SHA256 signature verification
- ✓ Multi-platform (amd64, arm64, arm, x86, ppc64le, s390x)

**Best For:**
- Production servers
- Microservices
- CI/CD runners
- Web services
- Game servers
- Stateless applications
- Container orchestration

**Not Ideal For:**
- Complex legacy software (may lack packages)
- glibc-dependent applications
- Heavy database operations
- Desktop applications

**Package Manager:**
```bash
# Update package list
apk update

# Install packages
apk add curl wget git

# Search for packages
apk search <name>

# Remove packages
apk del package-name
```

**See:** [Alpine 3.20 Recipe](./alpine/README.md)

---

### Debian Bookworm

Full-featured Linux distribution (~80 MB) with extensive package library and broad compatibility.

**Dockerfile:**
```dockerfile
FROM debian:bookworm
LABEL author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"
LABEL org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"

RUN apt-get update && apt-get install -y ca-certificates curl
RUN rm -rf /var/lib/apt/lists/*
USER nobody
```

**Pull:**
```bash
docker pull ghcr.io/nodebytehosting/oses:debian
```

**Features:**
- ✓ Comprehensive package library (~70,000+ packages)
- ✓ Excellent documentation and community support
- ✓ Long-term support (5+ years)
- ✓ glibc standard library (broader compatibility)
- ✓ apt/dpkg package managers
- ✓ Stable, production-proven
- ✓ Multi-platform support

**Best For:**
- Complex applications
- Legacy software
- Full development environments
- Applications requiring glibc
- When package availability is critical
- Educational/learning purposes

**Not Ideal For:**
- Minimal deployments (larger image)
- Resource-constrained environments
- When Alpine would suffice

**Package Manager:**
```bash
# Update package list
apt-get update

# Install packages
apt-get install -y curl wget git

# Search for packages
apt-cache search <name>

# Remove packages
apt-get remove package-name

# Clean up (reduce image size)
apt-get clean && rm -rf /var/lib/apt/lists/*
```

**See:** [Debian Bookworm Recipe](./debian/README.md)

---

### Ubuntu (Multiple Versions)

Full-featured Linux distribution with rolling release updates. Available in multiple versions.

**Available Versions:**
- `ubuntu_22.04` - LTS (April 2022 - April 2027)
- `ubuntu_24.04` - LTS (April 2024 - April 2029)
- `ubuntu_25.10` - Current Release (October 2025)
- `ubuntu_26.04` - Next LTS (April 2026)

**Dockerfile Example (26.04):**
```dockerfile
FROM ubuntu:26.04
LABEL author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"
LABEL org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"

RUN apt-get update && apt-get install -y ca-certificates curl
RUN rm -rf /var/lib/apt/lists/*
USER nobody
```

**Pull:**
```bash
docker pull ghcr.io/nodebytehosting/oses:ubuntu_26.04
```

**Features:**
- ✓ Latest tools and libraries
- ✓ Extended support options
- ✓ Excellent documentation and community
- ✓ Regular security updates (monthly)
- ✓ Enterprise support available
- ✓ Multi-platform builds (amd64, arm64)

**Best For:**
- Server deployments requiring latest tools
- Development environments
- Applications needing newer glibc versions
- LTS versions for production stability

**Package Manager:**
```bash
# Update package list
apt-get update

# Install packages
apt-get install -y curl wget git

# Search for packages
apt-cache search <name>

# Remove packages
apt-get remove package-name

# Clean up (reduce image size)
apt-get clean && rm -rf /var/lib/apt/lists/*
```

**See:** [Ubuntu Recipe](./ubuntu/README.md)

---

## Comparison

| Aspect | Alpine 3.20 | Debian Bookworm | Ubuntu 26.04 |
|--------|------------|-----------------|-------------|
| **Base Image Size** | ~3.6 MB | ~80 MB | ~90 MB |
| **C Library** | musl | glibc | glibc |
| **Package Manager** | apk | apt/dpkg | apt/dpkg |
| **Packages Available** | ~11,000 | ~70,000+ | ~70,000+ |
| **Boot Time** | Very Fast | Fast | Fast |
| **Memory Usage** | Minimal | Moderate | Moderate |
| **Build Time** | Fast | Normal | Normal |
| **Compatibility** | Good* | Excellent | Excellent |
| **Support Level** | Good | Excellent | Excellent |
| **Community** | Growing | Very Large | Very Large |
| **Release Cycle** | Stable | Stable | Rolling + LTS |
| **LTS Options** | No | Yes (5 years) | Yes (5+ years) |
| **Use Cases** | Production | General Purpose | General Purpose |

*Alpine has excellent compatibility but may lack packages or have differences (musl vs glibc).

## Choosing an OS

### Use Alpine 3.20 when:
- Building production servers and microservices
- Minimizing image size is important
- Deploying to resource-constrained environments
- You need fast startup and low memory overhead
- Applications are straightforward (no complex dependencies)
- Working with containerized runtimes (Node, Go, Rust, etc.)

### Use Debian Bookworm when:
- Maximum package availability is needed
- Running complex legacy applications
- Broad glibc compatibility is required
- Development environment is needed
- You need extensive documentation and community support
- Building custom installer/tool containers

### Use Ubuntu when:
- You need the latest tools and libraries
- Deploying to servers with Ubuntu already in use
- Preference for rolling releases (non-LTS) with latest features
- Long-term support (LTS versions) is required
- Enterprise support availability is important
- Standard Linux distribution is preferred

## Building Custom Images

### Minimal Alpine Image

```dockerfile
FROM ghcr.io/nodebytehosting/oses:alpine

# Install only what you need
RUN apk add --no-cache python3 py3-pip

WORKDIR /app
COPY app.py .

CMD ["python3", "app.py"]
```

### Development Debian Image

```dockerfile
FROM ghcr.io/nodebytehosting/oses:debian

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]
```

## Image Variants

Both OS recipes use official upstream images:

- `alpine:3.20` - Official Alpine Linux
- `debian:bookworm` - Official Debian

All images are:
- Multi-platform (amd64, arm64)
- Regularly updated for security patches
- Verified and signed
- Extensively tested

## Building Locally

### Build Alpine image

```bash
docker build -t my-alpine:latest oses/alpine/
docker tag my-alpine:latest ghcr.io/nodebytehosting/oses:alpine
docker push ghcr.io/nodebytehosting/oses:alpine
```

### Build Debian image

```bash
docker build -t my-debian:latest oses/debian/
docker tag my-debian:latest ghcr.io/nodebytehosting/oses:debian
docker push ghcr.io/nodebytehosting/oses:debian
```

### Build multi-platform

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/nodebytehosting/oses:alpine \
  --push oses/alpine/
```

## Image Tagging

- `ghcr.io/nodebytehosting/oses:alpine` - Latest Alpine 3.20
- `ghcr.io/nodebytehosting/oses:debian` - Latest Debian Bookworm
- `ghcr.io/nodebytehosting/oses:alpine-3.20` - Specific version
- `ghcr.io/nodebytehosting/oses:debian-bookworm` - Specific version

## CI/CD Pipeline

All OS images are automatically built and pushed:

- **Trigger**: Push to `oses/**` or schedule (monthly)
- **Alpine & Debian**: Multi-platform (linux/amd64, linux/arm64)
- **Ubuntu**: Multi-platform (linux/amd64, linux/arm64)
- **Registry**: ghcr.io (GitHub Container Registry)
- **Caching**: GitHub Actions cache for faster builds

See: `.github/workflows/oses.yml`

## Security

Both OS recipes include:

- ✓ Official, verified upstream images
- ✓ Regular security updates
- ✓ SHA256 signature verification
- ✓ Multi-platform verification
- ✓ Minimal attack surface

### Best Practices

1. **Use specific Alpine version** (3.20, not `latest`)
2. **Use specific Debian version** (bookworm, not `latest`)
3. **Update base images monthly** for security patches
4. **Run as non-root user** when possible
5. **Minimize installed packages** in Alpine
6. **Clean up package cache** in Debian
7. **Use `.dockerignore`** to reduce build context

## Troubleshooting

### Alpine: Package not found
```bash
# Search for package
apk search <name>

# Check available versions
apk search -v <name>

# Alpine has fewer packages - consider Debian
```

### Alpine: glibc compatibility issues
Some pre-compiled binaries expect glibc (not musl). Solutions:
1. Use Debian instead
2. Install `glibc` compatibility layer: `apk add glibc`
3. Recompile from source with musl

### Debian: Large image size
```bash
# Clean up after installation
RUN apt-get update && apt-get install -y <package> \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
```

### Slow package installation
- Alpine: `apk` is generally fast
- Debian: Consider caching layers or using multi-stage builds

## Related Documentation

- [Alpine Linux Official](https://alpinelinux.org/)
- [Debian Official](https://www.debian.org/)
- [Alpine Packages](https://pkgs.alpinelinux.org/)
- [Debian Packages](https://packages.debian.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Contributing

To update OS recipes:

1. Update `oses/[os]/Dockerfile` with new base version
2. Update `oses/[os]/README.md` if needed
3. Test locally: `docker build oses/[os]/`
4. Push to develop - workflow builds and pushes automatically

## License

MIT License - See [LICENSE](../../LICENSE) for details.
