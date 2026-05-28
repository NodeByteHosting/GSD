FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    wget \
    tar \
    gzip \
    openjdk-8-jre \
    openjdk-11-jre \
    openjdk-17-jre \
    openjdk-21-jre \
    openjdk-25-jre && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
COPY installers /app/installers

RUN chmod +x /app/entrypoint.sh && \
    chmod +x /app/installers/*.sh

EXPOSE 25565 25575

VOLUME ["data"]

ENTRYPOINT [ "/entrypoint.sh" ]