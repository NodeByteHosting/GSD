# Hytale Recipe

Docker recipe for running Hytale multiplayer servers. Debian-based with Java 25 JDK and Python 3 launcher. Includes automatic updates, version management, and advanced JVM optimizations.

## Files

- `Dockerfile` - Debian Bookworm image with Java 25 JDK, Python 3, and server utilities
- `entrypoint.py` - Python launcher with 4-phase execution flow
- `README.md` - This file

## Features

### 4-Phase Execution Flow
1. **Filesystem Preparation** - Create directories, migrate legacy layouts, validate environment
2. **Update Planning** - Check Maven, backups, or API for server updates
3. **Authentication** - Acquire OAuth2 tokens (optional, disabled by default)
4. **Startup** - Parse variables, inject JVM flags, launch server with signal forwarding

### Automatic Updates
- **Maven Integration** - Fetches latest releases from Hytale Maven repository
- **Version Tracking** - Maintains version history from JAR manifest
- **Smart Backups** - Automatic versioned backups before updates with retention policy
- **Rollback Support** - Restore from any previous backup instantly
- **Patchline Support** - Separate backups per patchline (release/pre-release)

### JVM Optimizations
- **AOT Caching** - Adaptive Optimization (created on first run, reused on subsequent runs)
- **Compact Object Headers** - Reduce memory footprint (default: enabled)
- **QUIC Transport** - Ultra-low latency network transport (default: QUIC, fallback: TCP)
- **Automatic Flag Injection** - JVM and server flags injected without user configuration

### Version Management
- **Automatic Detection** - Extracts version/patchline from JAR manifest
- **Per-Patchline Organization** - `.server-backups/{patchline}/{version}/`
- **Configurable Retention** - Keep N most recent versions per patchline
- **Update Strategies** - `latest`, `previous`, or specific version numbers

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  -v /path/to/hytale/server:/home/container \
  -p 8515:8515/tcp \
  -p 8516:8516/tcp \
  ghcr.io/nodebytehosting/games:hytale
```

### With Docker Compose

```yaml
version: '3.8'

services:
  hytale-server:
    image: ghcr.io/nodebytehosting/games:hytale
    environment:
      STARTUP: "java -Xmx2048M -jar Server/HytaleServer.jar nogui"
      SERVER_VERSION: latest
      AUTO_UPDATE: 1
      TRANSPORT: QUIC
    volumes:
      - hytale_data:/home/container
    ports:
      - "8515:8515/tcp"
      - "8516:8516/tcp"
    restart: unless-stopped

volumes:
  hytale_data:
```

### Build Locally

```bash
docker build -t hytale:latest games/hytale/
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  hytale:latest
```

## Configuration

### Required Environment Variables

| Variable | Description |
|----------|-------------|
| `STARTUP` | **Required** - Server startup command (e.g., `java -Xmx2048M -jar Server/HytaleServer.jar nogui`) |

### Update Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_VERSION` | latest | Version to run: `latest`, `previous`, or specific version (e.g., `2024.03.20-abc123`) |
| `AUTO_UPDATE` | 1 | Automatically check and download updates (0/1) |
| `PATCHLINE` | release | Update channel: `release` or `pre-release` |
| `SERVER_BACKUP_RETENTION` | 2 | Number of previous versions to keep per patchline |

### JVM & Performance

| Variable | Default | Description |
|----------|---------|-------------|
| `USE_AOT_CACHE` | 1 | Enable AOT (Adaptive Optimization) caching (0/1) |
| `COMPACT_HEADERS` | 1 | Use compact object headers to reduce memory (0/1) |
| `TRANSPORT` | QUIC | Network transport: `QUIC` (low latency) or `TCP` (compatibility) |
| `EARLY_PLUGINS` | 0 | Enable early plugins directory (0/1) |
| `ALLOW_OP` | 0 | Allow players to be granted OP (0/1) |

### Optional Features

| Variable | Default | Description |
|----------|---------|-------------|
| `HYTALE_API_AUTH` | 0 | Enable OAuth2 authentication (0/1) - requires browser authorization |
| `WORLD_BACKUP` | 0 | Enable automatic world backups (0/1) |
| `DISABLE_SENTRY` | 0 | Disable error reporting (0/1) |
| `IGNORE_BROKEN_MODS` | 0 | Continue with broken mods (0/1) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |

## Startup Examples

### Basic Server (QUIC)

```bash
STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui"
```

### With Custom Memory

```bash
STARTUP="java -Xmx4096M -jar Server/HytaleServer.jar nogui"
```

### With TCP Transport (Better Compatibility)

```bash
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  -e TRANSPORT=TCP \
  hytale:latest
```

### With Auto-Update Disabled

```bash
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  -e AUTO_UPDATE=0 \
  hytale:latest
```

### With Pre-Release Patchline

```bash
docker run -it \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  -e PATCHLINE=pre-release \
  hytale:latest
```

## How It Works

### Phase 1: Filesystem Preparation
- Creates `.tmp/` directory for temporary files
- Creates `Server/` directory for server binaries
- Migrates legacy layouts (old Hytale versions)
- Extracts version/patchline metadata from existing JAR

### Phase 2: Update Planning
The launcher determines the best update strategy:

1. **If `SERVER_VERSION=latest`**:
   - Checks Maven for latest release on configured patchline
   - Compares with local version
   - Uses latest from: Local → Backup → Maven API

2. **If `SERVER_VERSION=previous`**:
   - Restores the second-most-recent backed-up version

3. **If `SERVER_VERSION=<specific>`**:
   - Uses exact version if available in backups
   - Falls back to Maven API
   - Errors if version unavailable and no local files exist

### Phase 3: Authentication (Optional)
- Only runs if `HYTALE_API_AUTH=1`
- Requires browser authorization (OAuth2 device flow)
- Tokens cached locally for subsequent runs
- Automatically refreshed when expired

### Phase 4: JVM & Startup
- **JVM Flags Injected**:
  - Temp directory: `-Djava.io.tmpdir=/home/container/.tmp`
  - ANSI colors: `-Dterminal.ansi=true`
  - AOT cache: `-XX:AOTCache=...` or `-XX:AOTCacheOutput=...`
  - Compact headers: `-XX:+UseCompactObjectHeaders` (if enabled)

- **Server Flags Injected**:
  - Transport: `--transport QUIC` or `--transport TCP`
  - Feature flags: `--allow-op`, `--accept-early-plugins`, etc.

- **Variable Substitution**:
  - Pterodactyl-style: `{{MEMORY}}` → `4096`
  - Shell-style: `${MEMORY}` → `4096`
  - Any environment variable supported

- **Process Management**:
  - Runs in process group (OS setsid)
  - Signal forwarding: SIGTERM/SIGINT propagate to server
  - Clean shutdown on container stop

## Server Binaries

Hytale server binaries are **not** included in the Docker image. You must:

### Option 1: Volume Mount
Mount your server directory to `/home/container`:

```bash
docker run -it \
  -v /path/to/hytale/server:/home/container \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  hytale:latest
```

Expected structure:
```
/home/container/
├── Server/
│   ├── HytaleServer.jar          (required)
│   ├── Assets.zip                (required)
│   ├── config.json               (persisted)
│   ├── bans.json                 (persisted)
│   ├── whitelist.json            (persisted)
│   └── [other server files]
├── .server-backups/              (auto-created, backups)
├── .tmp/                         (auto-created, temp files)
└── version                       (auto-created, version tracking)
```

### Option 2: Game Service Provider (GSP)
Get server files from your Hytale Game Service Provider and mount them:

```bash
# Provider gives you: /path/to/gsp/hytale/
docker run -it \
  -v /path/to/gsp/hytale/:/home/container \
  -e STARTUP="java -Xmx2048M -jar Server/HytaleServer.jar nogui" \
  hytale:latest
```

## Memory Configuration

Set `-Xmx` JVM flag based on player count and world complexity:

| Expected Players | Recommended Xmx | Notes |
|------------------|-----------------|-------|
| 1-10 | 512M - 1024M | Small test/dev servers |
| 10-50 | 1024M - 2048M | Small community servers |
| 50-100 | 2048M - 4096M | Medium-sized servers |
| 100-200 | 4096M - 6144M | Large public servers |
| 200+ | 6144M - 8192M+ | Massive servers |

Example with 8GB allocation:
```bash
STARTUP="java -Xmx8192M -jar Server/HytaleServer.jar nogui"
```

## Backups & Rollback

### Automatic Backups
The launcher automatically backs up the current version before updating:

```
.server-backups/
├── release/
│   ├── 2024.03.20-abc123/
│   │   ├── Server/
│   │   │   ├── HytaleServer.jar
│   │   │   └── [config files]
│   │   └── Assets.zip
│   └── 2024.03.15-def456/
└── pre-release/
    └── 2024.03.25-ghi789/
```

### Rollback to Previous Version

```bash
docker run -it \
  -e SERVER_VERSION=previous \
  -v hytale_data:/home/container \
  hytale:latest
```

### Rollback to Specific Version

```bash
docker run -it \
  -e SERVER_VERSION=2024.03.15-def456 \
  -v hytale_data:/home/container \
  hytale:latest
```

### Configure Retention

Keep only 1 version (aggressive cleanup):
```bash
-e SERVER_BACKUP_RETENTION=1
```

Keep 5 versions (conservative):
```bash
-e SERVER_BACKUP_RETENTION=5
```

## Troubleshooting

### Server won't start
```bash
# Check if HytaleServer.jar exists
docker exec <container> ls -la /home/container/Server/

# View full output
docker logs <container>
```

### Java errors
```bash
# Verify Java installation
docker exec <container> java -version

# Check JVM heap usage
docker exec <container> jps -l
```

### High memory usage
- Reduce `-Xmx` value in `STARTUP`
- Disable AOT cache: `USE_AOT_CACHE=0`
- Disable compact headers: `COMPACT_HEADERS=0`
- Check `docker stats` during peak load

### Slow startup (first run)
- AOT cache is being created (normal, only on first run)
- Subsequent starts will be faster
- Disable with `USE_AOT_CACHE=0` if needed

### Update failures
- Verify internet connectivity: `docker exec <container> curl -I https://maven.hytale.com`
- Check patchline exists: `PATCHLINE=release` or `PATCHLINE=pre-release`
- Manually restore from backup: `SERVER_VERSION=previous`

### Port conflicts
- Ensure ports 8515 (UDP) and 8516 (TCP) are available
- Map to different host port: `-p 9000:8515/udp`

### Permission errors
- Ensure volume has write permissions
- Container runs as `container` user (UID 1000)
- Check: `chmod 755 /path/to/hytale/server`

## Performance Tips

### QUIC vs TCP
- **QUIC** (default): Ultra-low latency, better for players
- **TCP**: Better compatibility, use if QUIC has issues

```bash
-e TRANSPORT=TCP  # Fall back to TCP if QUIC fails
```

### AOT Cache (First-Run Optimization)
- First run: Slower (building AOT cache)
- Subsequent runs: Faster (using AOT cache)
- File: `.server-backups/.../HytaleServer.aot`

```bash
-e USE_AOT_CACHE=0  # Disable if causing issues
```

### Compact Headers (Memory Optimization)
- Reduces memory usage by ~5-10%
- Minimal performance impact
- Default: enabled

```bash
-e COMPACT_HEADERS=0  # Disable if compatibility issues
```

## Advanced Usage

### Update Schedule
Auto-update on container restart (recommended):
```bash
docker run -it \
  -e AUTO_UPDATE=1 \
  -e SERVER_VERSION=latest \
  --restart=on-failure \
  hytale:latest
```

### Read-Only Root Filesystem
Supported - entrypoint works with read-only mounts:
```bash
--read-only \
--tmpfs /home/container/.tmp \
-v hytale_data:/home/container
```

### Kubernetes Deployment
Example StatefulSet with persistent volume:
```yaml
volumeMounts:
  - name: data
    mountPath: /home/container
    subPath: hytale
env:
  - name: STARTUP
    value: "java -Xmx2048M -jar Server/HytaleServer.jar nogui"
  - name: SERVER_VERSION
    value: "latest"
```

## Related Documentation

- [Hytale Official](https://hytale.com)
- [Hytale Community](https://hytale.com/community)
- [Docker Documentation](https://docs.docker.com)
- [Java Performance Tuning](https://docs.oracle.com/en/java/javase/21/docs/guide/vm/performance-tuning-guide.html)
