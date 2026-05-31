#!/bin/bash

set -e

PROJECT="paper"
VERSION="${VERSION:-LATEST}"
USER_AGENT="nodebyte-minecraft/1.0 (support@nodebyte.host)"

echo "Installing Paper..."

LATEST_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds | \
	jq -r 'map(select(.channel == "STABLE")) | .[0] | .id')

if [ "$LATEST_BUILD" != "null" ]; then
	echo "Latest stable build is $LATEST_BUILD"
else
	echo "No stable build for version $MINECRAFT_VERSION found :("
fi
