# Game Recipes

Docker recipes for game servers. Built for Pterodactyl panels and our own GSM.

## Structure

```
rockstar/
  fivem/       - FiveM server with txAdmin
  redm/        - RedM server (coming soon)
```

Each recipe includes:
- `Dockerfile` - Container image
- `recipe.json` - Pterodactyl egg definition
- `start.sh` - Startup script
- `README.md` - Usage docs

## Available Recipes

### FiveM

GTA V multiplayer framework. Full txAdmin integration.

**Image:** `ghcr.io/nodebytehosting/games:fivem`

```bash
docker pull ghcr.io/nodebytehosting/games:fivem
```

See [rockstar/fivem/README.md](rockstar/fivem/README.md) for usage.

## Building

Images are automatically built and pushed to ghcr.io when changes are committed:

```
push to main/master → GitHub Actions builds → ghcr.io/nodebytehosting/games:fivem
```

### Manual Build

```bash
docker build -t ghcr.io/nodebytehosting/games:fivem rockstar/fivem/
docker push ghcr.io/nodebytehosting/games:fivem
```

Requires authentication:
```bash
docker login ghcr.io
```

## Using in Pterodactyl

1. Import the recipe from the repo
2. Select the game egg
3. Create a server
4. Configure environment variables

## Using in Custom Panels

Load `recipe.json` from each game directory. Point to the Docker image on ghcr.io.

## Contributing

Add new recipes:
1. Create `rockstar/GAME_NAME/` directory
2. Add `Dockerfile`, `start.sh`, `recipe.json`
3. Push to trigger automatic build
4. Update this README