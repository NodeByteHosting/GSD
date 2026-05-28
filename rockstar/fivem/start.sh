#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BLUE='\033[0;34m'

Text="${GREEN}[STARTUP]${NC}"

export TXHOST_GAME_NAME=${TXHOST_GAME_NAME:-"fivem"}
export TXHOST_DATA_PATH=${TXHOST_DATA_PATH:-"/home/container/txData"}
export TXHOST_INTERFACE=${TXHOST_INTERFACE:-"0.0.0.0"}
export TXHOST_TXA_PORT=${TXHOST_TXA_PORT:-"${TXADMIN_PORT:-40120}"}
export TXHOST_FXS_PORT=${TXHOST_FXS_PORT:-"${SERVER_PORT:-30120}"}
export TXHOST_DEFAULT_CFXKEY=${TXHOST_DEFAULT_CFXKEY:-"${FIVEM_LICENSE}"}
export TXHOST_MAX_SLOTS=${TXHOST_MAX_SLOTS:-"${MAX_PLAYERS}"}
export TXHOST_PROVIDER_NAME=${TXHOST_PROVIDER_NAME:-"${PROVIDER_NAME:-NodeByte Hosting}"}
export TXHOST_PROVIDER_LOGO=${TXHOST_PROVIDER_LOGO:-"${PROVIDER_LOGO}"}
export TXHOST_QUIET_MODE=${TXHOST_QUIET_MODE:-"false"}

echo -e "${Text} ${BLUE}Validating configuration...${NC}"

if [ -z "$TXHOST_DEFAULT_CFXKEY" ]; then
    echo -e "${Text} ${YELLOW}Warning: No FiveM license key provided. Set FIVEM_LICENSE or TXHOST_DEFAULT_CFXKEY${NC}"
fi

if [ "$TXHOST_TXA_PORT" -eq "30120" ] 2>/dev/null; then
    echo -e "${RED}[ERROR] TXHOST_TXA_PORT cannot be 30120${NC}"
    exit 1
fi

if [ "$TXHOST_FXS_PORT" -eq "40120" ] 2>/dev/null; then
    echo -e "${RED}[ERROR] TXHOST_FXS_PORT cannot be 40120${NC}"
    exit 1
fi

echo -e "${Text} ${GREEN}Configuration validated${NC}"
echo -e "${Text} Game: ${TXHOST_GAME_NAME}"
echo -e "${Text} txAdmin Port: ${TXHOST_TXA_PORT}"
echo -e "${Text} Server Port: ${TXHOST_FXS_PORT}"
echo -e "${Text} Max Slots: ${TXHOST_MAX_SLOTS:-unlimited}"

if [[ "${AUTO_UPDATE}" == "1" ]]; then
    echo -e "${Text} ${BLUE}Checking for updates...${NC}"
    
    CFX_CHANGELOGS=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$CFX_CHANGELOGS" ]; then
        DOWNLOAD_LINK=$(echo "$CFX_CHANGELOGS" | jq -r '.latest_download' 2>/dev/null)
        
        if [ -n "$DOWNLOAD_LINK" ] && [ "$DOWNLOAD_LINK" != "null" ]; then
            rm -rf /home/container/alpine > /dev/null 2>&1

            echo -e "${Text} ${BLUE}Downloading latest CitizenFX Resources...${NC}"

            curl -sSL "${DOWNLOAD_LINK}" -o "${DOWNLOAD_LINK##*/}" > /dev/null 2>&1
            tar -xvf "${DOWNLOAD_LINK##*/}" > /dev/null 2>&1
            rm -rf "${DOWNLOAD_LINK##*/}" run.sh > /dev/null 2>&1

            echo -e "${Text} ${GREEN}CitizenFX Resources updated successfully!${NC}"
        else
            echo -e "${Text} ${YELLOW}Could not determine latest download link${NC}"
        fi
    else
        echo -e "${Text} ${YELLOW}Update check failed (network or API issue)${NC}"
    fi
else 
    echo -e "${Text} ${BLUE}Auto Update is disabled (set AUTO_UPDATE=1 to enable)${NC}"
fi


echo -e "${Text} ${BLUE}Starting FiveM Server with txAdmin...${NC}"

SERVER_BIN_PATH="$(pwd)/alpine/opt/cfx-server/FXServer"
LD_PATH="$(pwd)/alpine/opt/cfx-server/ld-musl-x86_64.so.1"

if [ ! -f "$SERVER_BIN_PATH" ]; then
    echo -e "${RED}[ERROR] FiveM server binary not found at ${SERVER_BIN_PATH}${NC}"
    exit 1
fi

if [ ! -f "$LD_PATH" ]; then
    echo -e "${RED}[ERROR] Loader not found at ${LD_PATH}${NC}"
    exit 1
fi

if [ "$TXADMIN_ENABLE" == "1" ] || [ "$TXADMIN_ENABLE" != "0" ]; then
    TXADMIN_ARGS=""
else
    TXADMIN_ARGS="+exec server.cfg"
fi

"$LD_PATH" \
    --library-path "$(pwd)/alpine/usr/lib/v8/:$(pwd)/alpine/lib/:$(pwd)/alpine/usr/lib/:$(pwd)/alpine/opt/cfx-server/lib/" \
    -- "$SERVER_BIN_PATH" \
    +set citizen_dir "$(pwd)/alpine/opt/cfx-server/citizen/" \
    $TXADMIN_ARGS