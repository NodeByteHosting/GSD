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


FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"

LABEL       org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"
LABEL       org.opencontainers.image.description="Debian Bookworm base image for game servers and runtimes"
LABEL       org.opencontainers.image.licenses=MIT
LABEL       org.opencontainers.image.version="bookworm"

RUN         apt-get update && apt-get upgrade -y

RUN         apt-get install -y --no-install-recommends \
                ca-certificates \
                curl \
                git \
                iproute2 \
                locales \
                net-tools \
                tar \
                tzdata \
                wget

RUN         update-locale LANG=en_US.UTF-8 \
                && dpkg-reconfigure --frontend noninteractive locales \
                && useradd -m -d /home/container -s /bin/bash container \
                && apt-get clean && rm -rf /var/lib/apt/lists/*

USER        container
ENV         USER=container HOME=/home/container
ENV         DEBIAN_FRONTEND=noninteractive

WORKDIR     /home/container

STOPSIGNAL  SIGINT

ENTRYPOINT  ["/bin/bash"]