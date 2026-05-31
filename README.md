# Game Recipes

Docker recipes for game servers. Built for Pterodactyl panels and any custom game server managers.

## Structure

Recipes are organized by game franchise/publisher:

```
games/
  minecraft/        - Minecraft server recipes
  rockstar/         - Rockstar Games
    fivem/          - GTA V multiplayer (FiveM)
    redm/           - Red Dead Redemption 2 multiplayer (RedM)
```

## Recipe Format

Each recipe directory contains:
- `Dockerfile` - Container image definition
- `recipe.json` - Pterodactyl egg configuration
- `start.sh` - Server startup script
- `server.cfg` - Default server configuration template
- `README.md` - Usage and setup instructions

## Available Recipes

| Game | Image | Status |
|------|-------|--------|
| FiveM | `ghcr.io/nodebytehosting/games:fivem` | ✅ Available |
| RedM | `ghcr.io/nodebytehosting/games:redm` | 🔄 Coming soon |

## Build & Publish

Images automatically build and push to ghcr.io:

- **main** → `latest` + game-specific tag (e.g., `fivem`)
- **dev** → `game-dev` tag (e.g., `fivem-dev`)
- **tags** → semver tags (e.g., `fivem-v1.0.0`)

## Usage

### Pterodactyl

1. Import `recipe.json` as an egg
2. Create server with the egg
3. Configure environment variables in panel

### Custom Panels

Load the recipe and Docker image:

```javascript
const recipe = await fetch('https://raw.githubusercontent.com/nodebytehosting/game-recipes/main/games/rockstar/fivem/recipe.json').then(r => r.json());
const image = 'ghcr.io/nodebytehosting/games:fivem';
```

### Docker

```bash
docker pull ghcr.io/nodebytehosting/games:fivem
docker run -e FIVEM_LICENSE=your_key -p 30120:30120/udp ghcr.io/nodebytehosting/games:fivem
```

## Adding a New Recipe

1. **Create directory structure:**
   ```bash
   mkdir -p PUBLISHER/GAME_NAME
   ```

2. **Add required files:**
   - `Dockerfile` - Base image, dependencies, labels
   - `recipe.json` - Environment variables, server config
   - `start.sh` - Startup logic
   - `server.cfg` - Template configuration
   - `README.md` - Setup instructions

3. **Create GitHub Actions workflow:**
   ```bash
   cp .github/workflows/build-fivem.yml .github/workflows/build-GAME.yml
   ```
   Update image name and paths in the workflow.

4. **Push to trigger build:**
   - Create pull request or push to `develop`
   - GitHub Actions builds image as `GAME-dev`
   - Test and merge to `main` for release

## Recipe Checklist

- [ ] `Dockerfile` with proper labels and base image
- [ ] `recipe.json` with environment variables and metadata
- [ ] `start.sh` with configuration validation
- [ ] `server.cfg` template with comments
- [ ] `README.md` with quick-start examples
- [ ] GitHub Actions workflow configured
- [ ] `.dockerignore` for efficient builds
- [ ] `LICENSE` file included

## Tagging Strategy

| Branch | Tag Format | Use Case |
|--------|-----------|----------|
| `main` | `game` + `latest` | Production releases |
| `develop` | `game-dev` | Testing/staging |
| Tags | `game-vX.Y.Z` | Versioned releases |
| Commits | `game-sha-XXXX` | CI debugging |

## Troubleshooting

**Image not building?**
- Check workflow status: Actions tab
- Verify `Dockerfile` syntax
- Check `.github/workflows/` for your game

**Recipe not loading in Pterodactyl?**
- Verify image name in `recipe.json`
- Check Docker image exists on ghcr.io
- Validate JSON syntax in `recipe.json`

**Environment variables not working?**
- Check `start.sh` for variable export
- Verify `recipe.json` defines the variable
- Check Pterodactyl panel passes env vars to container
