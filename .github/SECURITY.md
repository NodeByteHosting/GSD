# Security Policy

## Supported Versions

- **Current**: Latest version on `main` branch is fully supported
- **Development**: `develop` branch is tested but may have unstable changes
- **Past releases**: Fix security issues on request

## Reporting Security Issues

**Do not** open a public issue for security vulnerabilities.

Instead, email security concerns to the project maintainers privately. Include:
- Description of the vulnerability
- Steps to reproduce (if applicable)
- Potential impact
- Suggested fix (if you have one)

We will acknowledge receipt within 48 hours and work on a fix.

## Security Best Practices

When using game-recipes in production:

1. **Keep images updated** - Rebuild regularly to get base image updates
2. **Use trusted sources** - Only pull from `ghcr.io/nodebytehosting/` on GitHub Container Registry
3. **Rotate credentials** - Change server licenses and API keys regularly
4. **Monitor logs** - Set up monitoring for container health checks
5. **Use secrets** - Never commit credentials; use Pterodactyl environment variables

## Dependencies

All recipes are based on Alpine Linux. Security patches are applied automatically when rebuilding.

To check for known vulnerabilities:
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ghcr.io/nodebytehosting/games:fivem
```
