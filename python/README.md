# Python Runtime

Docker images for Python applications and services. Supports multiple Python versions (3.7-3.11) with build tools and common data science/web frameworks.

## Files

- `3.7/Dockerfile` - Python 3.7 with development tools
- `3.8/Dockerfile` - Python 3.8 with development tools
- `3.9/Dockerfile` - Python 3.9 with development tools
- `entrypoint.sh` - Container entrypoint with STARTUP variable support
- `README.md` - This file

## Quick Start

### Standalone Docker

```bash
docker run -it \
  -e STARTUP="python app.py" \
  ghcr.io/nodebytehosting/python:python_3.9
```

### With Docker Compose

```yaml
version: '3.8'

services:
  python-app:
    image: ghcr.io/nodebytehosting/python:python_3.9
    environment:
      STARTUP: "python app.py"
      PYTHONUNBUFFERED: "1"
    volumes:
      - ./app:/home/container
    restart: unless-stopped
```

### Build Locally

```bash
docker build -t python:3.9 python/3.9/
docker run -it -e STARTUP="python app.py" python:3.9
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STARTUP` | - | Python command to execute (required) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |
| `PYTHONUNBUFFERED` | - | Set to `1` for unbuffered output |
| `PYTHONDONTWRITEBYTECODE` | - | Set to `1` to skip .pyc generation |
| `INTERNAL_IP` | auto | Internal container IP (auto-detected) |
| `USER` | container | Container user (read-only) |
| `HOME` | /home/container | Container home directory (read-only) |

### Variable Substitution

The entrypoint supports Pterodactyl-style variable substitution:

```bash
# Input
STARTUP="python app.py --port {{SERVER_PORT}} --bind {{INTERNAL_IP}}"

# Output
STARTUP="python app.py --port 8080 --bind 172.17.0.2"
```

## Pre-installed Tools

- `pip` - Python package manager
- `cmake` - Build system for C extensions
- `gcc`, `g++`, `make` - C/C++ compilation support
- `git` - Clone repositories
- `curl` - HTTP/HTTPS downloads
- `wget` - Alternative downloader
- `ca-certificates` - Certificate authorities

## Usage Examples

### Flask Web Application

```bash
docker run -it \
  -e STARTUP="python -m flask run --host=0.0.0.0" \
  -e PYTHONUNBUFFERED=1 \
  -p 5000:5000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/python:python_3.9
```

### Django Application

```bash
docker run -it \
  -e STARTUP="python manage.py runserver 0.0.0.0:8000" \
  -e PYTHONUNBUFFERED=1 \
  -p 8000:8000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/python:python_3.9
```

### FastAPI with Uvicorn

```bash
docker run -it \
  -e STARTUP="python -m uvicorn main:app --host 0.0.0.0 --port 8000" \
  -e PYTHONUNBUFFERED=1 \
  -p 8000:8000/tcp \
  -v ./app:/home/container \
  ghcr.io/nodebytehosting/python:python_3.9
```

### Data Science Script

```bash
docker run -it \
  -e STARTUP="python data_processor.py --input data.csv" \
  -v ./data:/home/container/data \
  -v ./output:/home/container/output \
  ghcr.io/nodebytehosting/python:python_3.9
```

### pip install from requirements.txt

```dockerfile
FROM ghcr.io/nodebytehosting/python:python_3.9

COPY requirements.txt /home/container/
RUN pip install --no-cache-dir -r /home/container/requirements.txt

COPY . /home/container/
```

## Python Version Information

| Version | Release Date | EOL Date |
|---------|--------------|----------|
| **3.7** | June 2018 | June 2023 |
| **3.8** | October 2019 | October 2024 |
| **3.9** | October 2020 | October 2025 |
| **3.10** | October 2021 | October 2026 |
| **3.11** | October 2022 | October 2027 |

- **Base**: Alpine 3.20
- **Platform**: linux/amd64, linux/arm64 (multiarch)
- **pip**: Latest version for each Python version

## Extending with Other Versions

To add support for additional Python versions, create new directories:

```bash
mkdir -p python/3.10 python/3.11
```

Update each Dockerfile to use the desired Python base:

```dockerfile
FROM python:3.11-alpine3.20
# ... rest of Dockerfile
```

Then add versions to the GitHub Actions workflow matrix:

```yaml
matrix:
  tag:
    - "3.7"
    - "3.8"
    - "3.9"
    - "3.10"
    - "3.11"
```

## Virtual Environment Considerations

Python virtual environments work in containers, but are less necessary:

```bash
# Not recommended - takes extra space
docker run -it ghcr.io/nodebytehosting/python:python_3.9 \
  bash -c "python -m venv /venv && source /venv/bin/activate && python app.py"

# Better - install directly
docker run -it ghcr.io/nodebytehosting/python:python_3.9 \
  bash -c "pip install -r requirements.txt && python app.py"
```

## Performance Tips

1. **Use `PYTHONUNBUFFERED=1`** - Ensures real-time output
2. **Use `PYTHONDONTWRITEBYTECODE=1`** - Saves disk space in containers
3. **Install only production deps** - `pip install -r requirements.txt --no-dev`
4. **Use Alpine's wheels** - Pre-compiled packages for faster installation
5. **Multi-stage builds** - Reduce final image size

## Troubleshooting

### Application won't start
- Check `STARTUP` variable is set
- Run `python --version` to verify Python is available
- Check application logs for errors

### Import errors with compiled packages
- Install build dependencies: `gcc`, `make`, `python3-dev`
- Use `pip install --no-cache-dir` to ensure fresh download
- Check for platform-specific wheel compatibility

### Memory issues
- Monitor with `free -m` and `ps aux`
- Limit pip workers: `pip install --no-cache-dir -r requirements.txt`
- Use `sys.getsizeof()` to profile memory usage

### Slow package installation
- Use `--no-cache-dir` to skip download cache
- Pre-compile wheels if installing frequently
- Use Alpine binary wheels when available

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/NodeByteHosting/game-recipes/issues
- Discord: https://discord.gg/Bg3Sf5fqa4
- Python Docs: https://docs.python.org/
- PyPI: https://pypi.org/
