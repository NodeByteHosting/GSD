FROM        --platform=$TARGETOS/$TARGETARCH ubuntu:26.04

LABEL       author="Tyler Hodgkin" maintainer="tyler.h@nodebyte.co.uk"

LABEL       org.opencontainers.image.source="https://github.com/nodebytehosting/recipes"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

## Add container user
RUN         useradd -m -d /home/container -s /bin/bash container
ENV         USER=container HOME=/home/container

## Update base packages
RUN         apt update \
            && apt upgrade -y

## Install dependencies
RUN         apt install -y --no-install-recommends gcc g++ gdb libc6 git wget curl tar zip unzip binutils xz-utils cabextract iproute2 net-tools netcat-openbsd telnet \
                libatomic1 sqlite3 locales ffmpeg apt-transport-https init-system-helpers \
                bzip2 zlib1g libssl3 tini \
                && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
                && locale-gen \
                && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR     /home/container

STOPSIGNAL  SIGINT

ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/bin/bash"]