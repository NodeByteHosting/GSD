#!/bin/bash

set -e

mkdir -p /data
cd /data

TYPE=$(echo "${TYPE:-PAPER}" | tr '[:lower:]' '[:upper:]')
VERSION=${VERSION:-LATEST}
JAVA_VERSION=${JAVA_VERSION:-21}
MEMORY=${MEMORY:-2G}

echo "Starting NodeByte Minecraft Runtime"
echo "Type: $TYPE"
echo "Version: $VERSION"
echo "Java: $JAVA_VERSION"

case $JAVA_VERSION in
    8)
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    ;;
    11)
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    ;;
    17)
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    ;;
    21)
        export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
    ;;
    25)
        export JAVA_HOME/usr/lib/jvm/java-25-openjdk-amd64
    ;;
    *)
    echo "Unsupported Java version: $JAVA_VERSION"
    exit 1
    ;;
esac

export PATH=$JAVA_HOME/bin:$PATH

java -version

INSTALLER="/app/installers/${TYPE,,}.sh"

if [ ! -f "$INSTALLER" ]; then
    echo "Unsupported server type: $TYPE"
    exit 1
fi

if [ ! -f installed.flag ]; then
    bash "$INSTALLER"
    touch installed.flag
fi

echo "eula=true" > eula.txt

if [ ! -f server.properties ] || [ "$OVERRIDE_SERVER_PROPERTIES" = "true" ]; then
    cat > server.properties <<EOF
        motd=${MOTD}
        difficulty=${DIFFICULTY}
        gamemode=${MODE}
        enable-command-block=${ENABLE_COMMAND_BLOCK}
        spawn-protection=${SPAWN_PROTECTION}
        max-players=${MAX_PLAYERS}
        allow-nether=${ALLOW_NETHER}
        online-mode=${ONLINE_MODE}
        pvp=${PVP}
        view-distance=${VIEW_DISTANCE}
        enable-rcon=${ENABLE_RCON}
        rcon.password=${RCON_PASSWORD}
        server-port=25565
        rcon.port=25575
    EOF
fi

if [ -f start.sh ]; then
    chmod +x start.sh
    exec ./start.sh
fi

exec java \
    -Xms${MEMORY} \
    -Xmx${MEMORY} \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -jar server.jar nogui
