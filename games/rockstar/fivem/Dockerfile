# FiveM Server Container
# Maintained by NodeByteHosting
# Based on Alpine Linux with FiveM server runtime
#
# Usage:
#   docker build -t ghcr.io/nodebytehosting/games:fivem .
#   docker push ghcr.io/nodebytehosting/games:fivem

FROM alpine:3.20

LABEL maintainer="NodeByte LTD" \
      description="FiveM server with txAdmin support" \
      version="1.0"

RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    libc6-compat \
    libstdc++ \
    && rm -rf /var/cache/apk/*

RUN addgroup -g 1000 container && \
    adduser -D -u 1000 -G container container

WORKDIR /home/container

RUN mkdir -p /home/container/txData && \
    chown -R container:container /home/container

# Copy startup scripts from context (build these into the image)
# In practice, these come from the recipe and are injected by Pterodactyl
# For standalone use, uncomment and copy:
# COPY --chown=container:container start.sh /home/container/start.sh
# COPY --chown=container:container entrypoint.sh /home/container/entrypoint.sh
# RUN chmod +x /home/container/start.sh /home/container/entrypoint.sh

USER container

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${TXADMIN_PORT:-40120}/api/getStatus 2>/dev/null || exit 1

ENV TXHOST_DATA_PATH=/home/container/txData \
    TXHOST_INTERFACE=0.0.0.0 \
    TXHOST_TXA_PORT=40120 \
    TXHOST_FXS_PORT=30120 \
    TXHOST_QUIET_MODE=false \
    AUTO_UPDATE=0 \
    TXADMIN_ENABLE=1

EXPOSE 40120/tcp 30120/udp

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["bash /home/container/start.sh"]
