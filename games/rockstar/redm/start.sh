#!/bin/bash
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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BLUE='\033[0;34m'

Text="${GREEN}[STARTUP]${NC}"

# Export configuration with defaults
export TXHOST_GAME_NAME=${TXHOST_GAME_NAME:-"redm"}
export TXHOST_DATA_PATH=${TXHOST_DATA_PATH:-"/home/container/txData"}
export TXHOST_INTERFACE=${TXHOST_INTERFACE:-"0.0.0.0"}
export TXHOST_TXA_PORT=${TXHOST_TXA_PORT:-"${TXADMIN_PORT:-40120}"}
export TXHOST_FXS_PORT=${TXHOST_FXS_PORT:-"${SERVER_PORT:-30120}"}
export TXHOST_DEFAULT_CFXKEY=${TXHOST_DEFAULT_CFXKEY:-"${REDM_LICENSE}"}
export TXHOST_MAX_SLOTS=${TXHOST_MAX_SLOTS:-"${MAX_PLAYERS}"}
export TXHOST_QUIET_MODE=${TXHOST_QUIET_MODE:-"false"}

echo -e "${Text} ${BLUE}Validating configuration...${NC}"

# Validate license key
if [ -z "$TXHOST_DEFAULT_CFXKEY" ]; then
    echo -e "${Text} ${YELLOW}Warning: No RedM license key provided. Set REDM_LICENSE or TXHOST_DEFAULT_CFXKEY${NC}"
fi

# Validate port assignments
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

# Auto-update RedM server binaries
if [[ "${AUTO_UPDATE}" == "1" ]]; then
    echo -e "${Text} ${BLUE}Checking for updates...${NC}"
    
    CFX_CHANGELOGS=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server/redm 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$CFX_CHANGELOGS" ]; then
        DOWNLOAD_LINK=$(echo "$CFX_CHANGELOGS" | jq -r '.latest_download' 2>/dev/null)
        
        if [ -n "$DOWNLOAD_LINK" ] && [ "$DOWNLOAD_LINK" != "null" ]; then
            rm -rf /home/container/redm > /dev/null 2>&1
            mkdir -p /home/container/redm

            echo -e "${Text} ${BLUE}Downloading latest RedM Resources...${NC}"

            curl -sSL "${DOWNLOAD_LINK}" -o "/tmp/redm-server.tar.gz" > /dev/null 2>&1
            tar -xzf "/tmp/redm-server.tar.gz" -C /home/container/redm > /dev/null 2>&1
            rm -rf "/tmp/redm-server.tar.gz" /home/container/redm/run.sh > /dev/null 2>&1

            echo -e "${Text} ${GREEN}RedM Resources updated successfully!${NC}"
        else
            echo -e "${Text} ${YELLOW}Could not determine latest download link${NC}"
        fi
    else
        echo -e "${Text} ${YELLOW}Update check failed (network or API issue)${NC}"
    fi
else 
    echo -e "${Text} ${BLUE}Auto Update is disabled (set AUTO_UPDATE=1 to enable)${NC}"
fi

echo -e "${Text} ${BLUE}Starting RedM Server with txAdmin...${NC}"

SERVER_BIN_PATH="$(pwd)/redm/opt/cfx-server/FXServer"
LD_PATH="$(pwd)/redm/opt/cfx-server/ld-musl-x86_64.so.1"

if [ ! -f "$SERVER_BIN_PATH" ]; then
    echo -e "${RED}[ERROR] RedM server binary not found at ${SERVER_BIN_PATH}${NC}"
    exit 1
fi

# Execute server
exec "$SERVER_BIN_PATH"

