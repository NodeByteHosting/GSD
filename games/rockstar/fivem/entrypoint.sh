#!/bin/ash
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

set -e

cd /home/container || exit 1

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${GREEN}[STARTUP]${NC} FiveM Server Starting"

# Export internal IP for FiveM
export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}' 2>/dev/null || echo "127.0.0.1")

# Set environment defaults
export TXHOST_GAME_NAME=${TXHOST_GAME_NAME:-"fivem"}
export TXHOST_DATA_PATH=${TXHOST_DATA_PATH:-"/home/container/txData"}
export TXHOST_INTERFACE=${TXHOST_INTERFACE:-"0.0.0.0"}
export TXHOST_TXA_PORT=${TXHOST_TXA_PORT:-"${TXADMIN_PORT:-40120}"}
export TXHOST_FXS_PORT=${TXHOST_FXS_PORT:-"${SERVER_PORT:-30120}"}

echo "${GREEN}[STARTUP]${NC} ${BLUE}Validating configuration...${NC}"

# Validate license key
if [ -z "${FIVEM_LICENSE}" ]; then
    echo "${GREEN}[STARTUP]${NC} ${YELLOW}Warning: No FiveM license key provided. Set FIVEM_LICENSE${NC}"
fi

# Validate port conflicts
if [ "${TXHOST_TXA_PORT}" = "30120" ]; then
    echo "${RED}[ERROR] TXHOST_TXA_PORT cannot be 30120 (reserved for FXServer)${NC}"
    exit 1
fi

if [ "${TXHOST_FXS_PORT}" = "40120" ]; then
    echo "${RED}[ERROR] TXHOST_FXS_PORT cannot be 40120 (reserved for txAdmin)${NC}"
    exit 1
fi

echo "${GREEN}[STARTUP]${NC} ${GREEN}Configuration validated${NC}"
echo "${GREEN}[STARTUP]${NC} Game: ${TXHOST_GAME_NAME}"
echo "${GREEN}[STARTUP]${NC} txAdmin Port: ${TXHOST_TXA_PORT}"
echo "${GREEN}[STARTUP]${NC} Server Port: ${TXHOST_FXS_PORT}"

# Check for auto-updates if enabled
if [ "${AUTO_UPDATE}" = "1" ]; then
    echo "${GREEN}[STARTUP]${NC} ${BLUE}Checking for server updates...${NC}"
    CHANGELOGS=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server 2>/dev/null || echo "")
    if [ -n "${CHANGELOGS}" ]; then
        LATEST=$(echo "${CHANGELOGS}" | grep -o '"latest_download":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
        if [ -n "${LATEST}" ] && [ -d "./alpine/opt/cfx-server" ]; then
            echo "${GREEN}[STARTUP]${NC} Update check passed"
        fi
    fi
fi

echo "${GREEN}[STARTUP]${NC} ${GREEN}Starting FXServer...${NC}"

# Execute FiveM server directly (startup command from Pterodactyl egg)
exec $(pwd)/alpine/opt/cfx-server/ld-musl-x86_64.so.1 \
    --library-path "$(pwd)/alpine/usr/lib/v8/:$(pwd)/alpine/lib/:$(pwd)/alpine/usr/lib/" \
    -- $(pwd)/alpine/opt/cfx-server/FXServer \
    +set citizen_dir $(pwd)/alpine/opt/cfx-server/citizen/ \
    +set sv_licenseKey ${FIVEM_LICENSE} \
    +set steam_webApiKey ${STEAM_WEBAPIKEY} \
    +set sv_maxplayers ${MAX_PLAYERS} \
    $( [ "${TXADMIN_ENABLE}" = "1" ] && printf %s '+start_txadmin' || printf %s '+exec server.cfg' )