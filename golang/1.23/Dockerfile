#
# Copyright (c) 2026 NodeByte LTD
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

FROM        --platform=$TARGETOS/$TARGETARCH golang:1.23-alpine

LABEL       author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"

LABEL       org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"
LABEL       org.opencontainers.image.description="Go 1.23 runtime for containerized applications"
LABEL       org.opencontainers.image.version="1.23"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apk add --update --no-cache \
              ca-certificates \
              tzdata \
              git \
              make \
              gcc \
              musl-dev \
            && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

ENV         RECIPE_EOL_NAG_WARNING=1

COPY        --chmod=755 --chown=root:root ../entrypoint.sh /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
            CMD test -f /proc/1/cmdline || exit 1

ENTRYPOINT  ["/entrypoint.sh"]