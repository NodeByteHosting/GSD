# Java Runtime

Docker images for Java-based applications (Minecraft servers, Spring applications, etc.). Uses Eclipse Temurin JDK with Debian base.

## Available Versions

| Version | Status | JDK Type | Image Name |
|---------|--------|----------|------------|
| 8 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_8` |
| 8 (with Project Jigsaw) | Supported | Project Jigsaw | `ghcr.io/nodebytehosting/java:java_8j9` |
| 11 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_11` |
| 11 (with Project Jigsaw) | Supported | Project Jigsaw | `ghcr.io/nodebytehosting/java:java_11j9` |
| 16 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_16` |
| 16 (with Project Jigsaw) | Supported | Project Jigsaw | `ghcr.io/nodebytehosting/java:java_16j9` |
| 17 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_17` |
| 19 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_19` |
| 21 | LTS | HotSpot | `ghcr.io/nodebytehosting/java:java_21` |
| 22 | Supported | HotSpot | `ghcr.io/nodebytehosting/java:java_22` |
| 25 | Latest | HotSpot | `ghcr.io/nodebytehosting/java:java_25` |
| 26 | Latest LTS | HotSpot | `ghcr.io/nodebytehosting/java:java_26` |

## Files

- `[version]/Dockerfile` - Java JDK with development tools for specified version
- `entrypoint.sh` - Container entrypoint with STARTUP variable support
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="java -jar app.jar" \
  -p 8080:8080/tcp \
  ghcr.io/nodebytehosting/java:java_25
```

### With Docker Compose

```yaml
version: '3.8'

services:
  java-app:
    image: ghcr.io/nodebytehosting/java:java_25
    ports:
      - "8080:8080/tcp"
    environment:
      STARTUP: "java -Xmx1024m -jar app.jar"
      TZ: UTC
    volumes:
      - ./app:/home/container
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t java:25 java/25/
docker run -it -e STARTUP="java -jar app.jar" java:25
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Java command to execute (required) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected) |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

### Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="java -Xmx{{MEMORY}}m -Xms{{MEMORY}}m -jar server.jar"

# Output
STARTUP="java -Xmx2048m -Xms2048m -jar server.jar"
```

## Pre-installed Tools

- `lsof` - List open files
- `curl` - HTTP/HTTPS downloads
- `wget` - Alternative downloader
- `git` - Clone repositories
- `tar` - Archive extraction
- `sqlite3` - Database utility
- `openssl` - SSL/TLS utilities
- `ca-certificates` - Certificate authorities
- `fontconfig`, `libfreetype6` - Font rendering
- `libstdc++6` - C++ runtime

## Usage Examples

### Minecraft Server (Spigot/Paper)

```bash
docker run -it \
  -e STARTUP="java -Xmx2048m -Xms1024m -jar server.jar nogui" \
  -p 25565:25565/tcp \
  -v ./server:/home/container \
  ghcr.io/nodebytehosting/java:java_25
```

### Spring Boot Application

```bash
docker run -it \
  -e STARTUP="java -jar app.jar --server.port=8080" \
  -p 8080:8080/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/java:java_25
```

### With Custom JVM Arguments

```bash
docker run -it \
  -e STARTUP="java -Xmx4096m -Xms2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar app.jar" \
  ghcr.io/nodebytehosting/java:java_25
```

## Java Version Information

- **Java 25** - Latest version (September 2024)
- **Base**: Eclipse Temurin JDK (open-source OpenJDK build)
- **OS**: Debian Bookworm slim
- **Platform**: linux/amd64, linux/arm64 (multiarch)

## Extending with Other Versions

To add support for other Java versions, create additional directories:

```bash
mkdir -p java/21 java/17 java/11
```

Update each Dockerfile to use the desired Eclipse Temurin base:

```dockerfile
FROM eclipse-temurin:21-jdk
# ... rest of Dockerfile
```

Then add versions to the GitHub Actions workflow matrix:

```yaml
matrix:
  tag:
    - 11
    - 17
    - 21
    - 25
```

## Performance Tips

1. **Set JVM memory limits** - Use `-Xmx` and `-Xms` for consistent performance
2. **Use G1GC for large heaps** - `-XX:+UseG1GC` for heaps > 4GB
3. **Enable aggressive optimization** - `-XX:+AggressiveOptimization` for compute-intensive apps
4. **Monitor with tools** - `jps`, `jstat`, `jconsole` available in container
5. **Use volume mounts** - Mount application directory to persist data and logs

## Troubleshooting

### Application won't start
- Check `STARTUP` variable is set correctly
- Run `java -version` to verify Java is available
- Check application logs for Java errors

### Out of memory errors
- Increase `-Xmx` value (max heap size)
- Check container memory limits: `docker stats`
- Monitor with `jstat -gc <pid> 1000`

### Class not found errors
- Verify JAR file is in `/home/container`
- Check classpath with `java -cp` if using multiple JARs
- Ensure all dependencies are included

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Java Docs: https://docs.oracle.com/en/java/
- Eclipse Temurin: https://adoptium.net/
