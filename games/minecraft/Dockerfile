#
# Copyright (c) 2026 NodeByte LTD
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM        --platform=$TARGETOS/$TARGETARCH alpine:3.20

LABEL       author="Rizon" maintainer="rizon@nodebyte.co.uk"

LABEL       org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"
LABEL       org.opencontainers.image.description="Minecraft server with multiple Java versions"
LABEL       org.opencontainers.image.licenses=MIT
LABEL       org.opencontainers.image.version="latest"

RUN         apk add --update --no-cache \
              bash \
              ca-certificates \
              curl \
              git \
              jq \
              openjdk8-jre \
              openjdk11-jre \
              openjdk17-jre \
              openjdk21-jre \
              tar \
              tzdata \
              wget \
            && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        --chmod=755 --chown=container:container entrypoint.sh /entrypoint.sh
COPY        --chmod=755 --chown=container:container installers /home/container/installers

EXPOSE      25565/tcp 25575/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
            CMD test -f /proc/1/cmdline || exit 1

ENTRYPOINT  ["/entrypoint.sh"]