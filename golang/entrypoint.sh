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

# Default the TZ environment variable to UTC
TZ=${TZ:-UTC}
export TZ

# Get internal Docker IP with fallback
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || echo "127.0.0.1")
export INTERNAL_IP

# Verify we can access the container directory
if ! cd /home/container 2>/dev/null; then
    echo "ERROR: Cannot access /home/container"
    exit 1
fi

# Verify Go is available
if ! go version >/dev/null 2>&1; then
    echo "ERROR: Go is not available"
    exit 1
fi

printf "\033[1m\033[33mcontainer@nodebyte~ \033[0mgo version\n"
go version

# Check for end-of-life marker
if [ "${RECIPE_EOL_NAG_WARNING+x}" ]; then
    cat >&2 <<'EOF'
======================================================================
DEPRECATION WARNING:
This version of the Go recipe has been marked as end-of-life.
Please migrate to a supported version as soon as possible to ensure
continued security updates and support.
======================================================================
EOF
    sleep "${RECIPE_EOL_NAG_DELAY:-10}"
fi

# Validate STARTUP command is set
if [ -z "${STARTUP}" ]; then
    echo "ERROR: STARTUP environment variable is not set"
    exit 1
fi

# Parse {{VARIABLE}} -> ${VARIABLE} format
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Verify we have something to execute
if [ -z "${PARSED}" ]; then
    echo "ERROR: Failed to parse STARTUP command"
    exit 1
fi

# Display command and execute
printf "\033[1m\033[33mcontainer@nodebyte~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}