# Rockstar Game Recipes

Docker recipes for Rockstar game multiplayer servers powered by CFX.re (formerly FiveM/RedM).

## Quick Reference

| Game | Framework | Status | Image |
|------|-----------|--------|-------|
| GTA V | FiveM | Production | `ghcr.io/nodebytehosting/games:fivem` |
| RDR 2 | RedM | Coming Soon | `ghcr.io/nodebytehosting/games:redm` |

## Directory Structure

```
rockstar/
├── README.md              # This file
├── fivem/                 # GTA V multiplayer server
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── recipe.json
│   └── README.md
└── redm/                  # Red Dead Redemption 2 multiplayer server
    ├── Dockerfile
    ├── entrypoint.sh
    ├── recipe.json
    └── README.md
```

## Game Recipes

### FiveM (GTA V)

Grand Theft Auto V multiplayer server via CFX.re framework. Includes built-in economy, admin system, and extensive modding capabilities.

```bash
docker run -it \
  -e STARTUP="./FXServer.sh" \
  -e AUTHORITATIVE=1 \
  -e MAXPLAYERS=32 \
  -p 30120:30120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:fivem
```

**Quick Start:**
- See [FiveM Recipe](./fivem/README.md) for full documentation

**Features:**
- Automatic FXServer binary updates
- CFX.re resource ecosystem
- Built-in admin commands
- Character persistence
- Job system
- Virtual economy
- Multi-platform support

---

### RedM (RDR 2)

Red Dead Redemption 2 multiplayer server via CFX.re framework. Similar to FiveM with Wild West themed gameplay.

```bash
docker run -it \
  -e STARTUP="./FXServer.sh" \
  -e AUTHORITATIVE=1 \
  -p 30120:30120/tcp \
  -p 30120:30120/udp \
  ghcr.io/nodebytehosting/games:redm
```

**Quick Start:**
- See [RedM Recipe](./redm/README.md) for full documentation

**Features:**
- Automatic FXServer binary updates
- CFX.re resource ecosystem
- Western gameplay framework
- RP and economy systems
- Admin management
- Multi-platform support

---

## CFX.re Framework Overview

Both FiveM and RedM use CFX.re (formerly CitizenFX), a modification framework providing:

### Core Features

- **Resource System** - Modular code organization
- **Scripting** - Lua and JavaScript support
- **Networking** - Optimized multiplayer architecture
- **Persistence** - Character and data storage
- **Admin Tools** - Ban lists, permissions, commands
- **API** - Extensive server and client APIs
- **Marketplace** - Community resources and scripts

### Resources

Resources are individual game mods/scripts. Installation methods:

1. **Direct folder** - Place in `server-data/resources/`
2. **Git clone** - Git-managed resources
3. **Releases** - Download releases from GitHub
4. **Package managers** - Community package systems

### Configuration

Main configuration: `server.cfg`

```ini
# Server name and description
sv_projectName "My Server"
sv_projectDesc "Description"

# Server settings
sv_maxclients 32
sv_enforceGameBuild 2699  # Specific GTA V version

# Licensing
sv_licenseKey "your-key-here"

# Features
set onesync on              # Optimized entity syncing
set onesync_enableInfinity on
set PlayerLoadoutGl false

# Resources to start
ensure mapmanager
ensure chat
ensure spawnmanager
ensure sessionmanager
```

### Admin Commands

Common admin commands (resource-dependent):
- `/ban <player> <reason>`
- `/unban <id>`
- `/kick <player> <reason>`
- `/adminadd <player>`
- `/admindel <player>`

---

## Shared Features

Both Rockstar recipes include:

- **Alpine Base** - Minimal, production-ready
- **Auto-Updates** - Latest FXServer binaries on startup
- **Resource Management** - Easy resource loading
- **Health Checks** - Automatic monitoring
- **Logging** - Persistent console output
- **Pterodactyl Support** - Variable substitution
- **Multi-platform** - amd64 and arm64

## Building Locally

### Build FiveM

```bash
docker build -t my-fivem:latest games/rockstar/fivem/
docker run -it -p 30120:30120/tcp -p 30120:30120/udp my-fivem:latest
```

### Build RedM

```bash
docker build -t my-redm:latest games/rockstar/redm/
docker run -it -p 30120:30120/tcp -p 30120:30120/udp my-redm:latest
```

## Common Issues & Troubleshooting

### Server won't start
1. Check `STARTUP` variable set
2. Verify FXServer downloaded: `docker logs <container>`
3. Check `server.cfg` syntax

### Resource fails to load
1. Check resource folder structure
2. Verify resource names in `fxmanifest.lua`
3. Check for dependency conflicts

### Players can't connect
1. Verify ports open: `netstat -tlnp | grep 30120`
2. Check firewall rules
3. Verify internal IP routing

### High resource usage
1. Reduce entity sync frequency
2. Optimize Lua scripts
3. Check for memory leaks
4. Monitor: `docker stats`

---

## Related Resources

- [CFX.re Official](https://cfx.re/)
- [FiveM Resources](https://forum.cfx.re/)
- [RedM Resources](https://forum.cfx.re/c/redm/22)
- [FiveM Documentation](https://docs.fivem.net/)
- [RedM Documentation](https://docs.redm.net/)

## Contributing

To improve Rockstar recipes:

1. Test locally
2. Submit improvements to individual recipe READMEs
3. Update configuration examples
4. Report issues

## License

MIT License - See [LICENSE](../../../LICENSE) for details.

---

**For detailed documentation:**
- [FiveM Recipe](./fivem/README.md)
- [RedM Recipe](./redm/README.md)
