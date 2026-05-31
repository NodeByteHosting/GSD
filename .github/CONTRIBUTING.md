# Contributing Guide

## Adding a New Game Recipe

### Structure
Each game recipe lives in `games/{publisher}/{game}/`:

```
games/
  rockstar/
    fivem/
      Dockerfile
      start.sh
      recipe.json
      README.md
      .dockerignore
```

### Required Files

1. **Dockerfile** - Alpine-based container image (keep it minimal)
2. **start.sh** - Server startup script with configuration handling
3. **recipe.json** - Pterodactyl egg definition (PTDL_v2 format)
4. **README.md** - Quick start and usage guide
5. **.dockerignore** - Exclude unnecessary files from build context

### Checklist

- [ ] Create directory structure `games/{publisher}/{game}/`
- [ ] Add Dockerfile using Alpine base
- [ ] Create start.sh with environment variable handling
- [ ] Define recipe.json with proper Pterodactyl format
- [ ] Write clear README with examples
- [ ] Add game to matrix in `games.yml`:
  ```yaml
  matrix:
    game:
      - minecraft
      - rockstar/fivem
      - rockstar/redm  # your new game here
  ```
- [ ] Push to develop branch (triggers workflow test)
- [ ] Verify build succeeds in Actions

### Code Standards

- **Dockerfile**: Use Alpine 3.20, create non-root user, include health checks
- **start.sh**: Validate inputs, map Pterodactyl variables, use bash `set -e`
- **Environment Variables**: Support both new and legacy variable names for backward compatibility
- **Logging**: Output errors with clear prefixes (ERROR, WARN)

### Testing

1. Build locally: `docker build -f games/{publisher}/{game}/Dockerfile -t test .`
2. Run container with env vars: `docker run -e KEY=value test`
3. Verify server starts and responds to health checks

## Updating Go Recipe Versions

Add versions to the matrix in `go.yml`:

```yaml
matrix:
  version:
    - "1.14"
    - "1.15"    # add here
```

Then create `golang/{version}/Dockerfile`.

## Pull Requests

- Keep commits focused and descriptive
- Reference issues when applicable
- Test changes locally before pushing
- Expect workflows to run on develop branch automatically

## Questions?

Open an issue with the `question` label.
