# Go Runtime

Docker images for Go applications and services. Includes build tools for compiling Go binaries.

## Files

- `1.14/Dockerfile` - Go 1.14 development environment
- `entrypoint.sh` - Container entrypoint with STARTUP variable support
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="./app" \
  ghcr.io/nodebytehosting/golang:golang_1.14
```

### With Docker Compose

```yaml
version: '3.8'

services:
  go-app:
    image: ghcr.io/nodebytehosting/golang:golang_1.14
    environment:
      STARTUP: "./myapp"
      PORT: "8080"
    volumes:
      - ./app:/home/container
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t go:1.14 golang/1.14/
docker run -it -e STARTUP="./app" go:1.14
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Go application to execute (required) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected) |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

### Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="./app --port {{SERVER_PORT}} --bind {{INTERNAL_IP}}"

# Output
STARTUP="./app --port 8080 --bind 172.17.0.2"
```

## Pre-installed Tools

- `git` - Clone repositories
- `make` - Build automation
- `gcc`, `musl-dev` - C compilation support
- `curl` - HTTP/HTTPS downloads
- `wget` - Alternative downloader
- `ca-certificates` - Certificate authorities

## Usage Examples

### Simple Go Service

```bash
docker run -it \
  -e STARTUP="./server" \
  -p 8080:8080/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/golang:golang_1.14
```

### With Command-line Arguments

```bash
docker run -it \
  -e STARTUP="./app --config /home/container/config.yml --verbose" \
  ghcr.io/nodebytehosting/golang:golang_1.14
```

### Multi-stage Build Example

```dockerfile
FROM ghcr.io/nodebytehosting/golang:golang_1.14 as builder

WORKDIR /home/container
COPY . .
RUN go build -o app .

FROM alpine:latest
COPY --from=builder /home/container/app /app
ENTRYPOINT ["/app"]
```

## Go Version Information

- **Go 1.14** - Included in this image
- **Base**: Alpine 3.20
- **Platform**: linux/amd64, linux/arm64 (multiarch)
- **Compiler**: GCC available for cgo support

## Extending with Other Versions

To add support for other Go versions, create additional directories:

```bash
mkdir -p golang/1.15 golang/1.16 golang/1.17
```

Update each Dockerfile to use the desired Go base:

```dockerfile
FROM golang:1.17-alpine3.20
# ... rest of Dockerfile
```

Then add versions to the GitHub Actions workflow matrix:

```yaml
matrix:
  tag:
    - "1.14"
    - "1.15"
    - "1.16"
    - "1.17"
```

## Performance Tips

1. **Use multi-stage builds** - Reduces final image size significantly
2. **Set build flags** - `-ldflags "-s -w"` to strip debug symbols
3. **Enable CGO for cgo** - Already available with gcc
4. **Use Go modules** - Ensure `go.mod` and `go.sum` are present
5. **Build with optimizations** - `-ldflags "-s"` removes debug info

## Troubleshooting

### Application won't start
- Check `STARTUP` variable is set
- Run `go version` to verify Go is available
- Check application logs for errors

### Permission denied errors
- Ensure binary has execute permissions: `chmod +x app`
- Check file ownership: `ls -la /home/container/`

### High memory usage
- Use `GOGC` environment variable to adjust garbage collection
- Monitor with `ps aux` inside container

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Go Docs: https://golang.org/doc/
