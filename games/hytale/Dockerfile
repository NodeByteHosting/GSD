#
# MIT License
#
# Copyright (c) 2024 NodeByte Hosting
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

FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:25-jdk-noble

LABEL author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"
LABEL org.opencontainers.image.source="https://github.com/nodebytehosting/recipes" \
      org.opencontainers.image.description="Hytale multiplayer server" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="latest"

RUN apt update -y \
    && apt install -y \
        curl \
        ca-certificates \
        fontconfig \
        tzdata \
        tini \
        unzip \
        dbus \
        tar \
        zip \
        sqlite3 \
        git \
        openssl \
        lsof \
        file \
        python3-minimal \
        python3-requests \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

## Configure locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## Setup user and working directory
RUN useradd -m -d /home/container -s /bin/bash container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY --chmod=755 --chown=container:container entrypoint.py /entrypoint.py
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/usr/bin/python3", "/entrypoint.py"]