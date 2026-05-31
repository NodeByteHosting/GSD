#!/bin/bash

set -e

PROJECT="paper"
VERSION="${VERSION:-LATEST}"
USER_AGENT="nodebyte-minecraft/1.0 (support@nodebyte.host)"

echo "Installing Paper..."

if [ "$VERSION" = "LATEST" ]; then
	VERSION=$(curl -s -H "User-Agent: $USER_AGENT" \
    "https://fill.papermc.io/v3/projects/${PROJECT}/versions" \
    | jq -r '.versions[-1]')
fi

echo "Target MC version: $VERSION"

BUILDS_JSON=$(curl -s -H "User-Agent: $USER_AGENT" \
	"https://fill.papermc.io/v3/projects/${PROJECT}/versions/${VERSION}/builds")

LATEST_STABLE_BUILD=$(echo "$BUILDS_JSON" \
	| jq -c 'map(select(.channel == "STABLE")) | .[-1]')

if [ -z "$LATEST_STABLE_BUILD" ] || [ "$LATEST_STABLE_BUILD" = "null" ]; then
	echo "No stable build found for version $VERSION using v3 API."
	exit 1
fi

BUILD_ID=$(echo "$LATEST_STABLE_BUILD" | jq -r '.id')
echo "Selected build: $BUILD_ID"

FILE=$(echo "$LATEST_STABLE_BUILD" | jq -r '.downloads["server:default"].name')
DOWNLOAD_URL=$(echo "$LATEST_STABLE_BUILD" | jq -r '.downloads["server:default"].url')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
	echo "Failed to retrieve a download URL from the v3 response."
	exit 1
fi

echo "Downloading: $FILE"

curl -L -H "User-Agent: $USER_AGENT" \
  -o server.jar "$DOWNLOAD_URL"

echo "Paper installed successfully."
