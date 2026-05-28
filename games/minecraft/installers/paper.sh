#!/bin/bash

set -e

PROJECT="paper"
VERSION="${VERSION:-LATEST}"
USER_AGENT="nodebyte-minecraft/1.0 (support@nodebyte.host)"

echo "Installing Paper..."

# 1. Resolve latest Minecraft version if needed
if [ "$VERSION" = "LATEST" ]; then
  VERSION=$(curl -s -H "User-Agent: $USER_AGENT" \
    https://fill.papermc.io/v3/projects/${PROJECT}/versions \
    | jq -r '.versions[-1]')
fi

echo "Target MC version: $VERSION"

# 2. Get latest stable build list
BUILDS_JSON=$(curl -s -H "User-Agent: $USER_AGENT" \
  "https://fill.papermc.io/v3/projects/${PROJECT}/versions/${VERSION}/builds")

# 3. Extract latest STABLE build ID
BUILD=$(echo "$BUILDS_JSON" \
  | jq -r 'map(select(.channel == "STABLE")) | .[-1].id')

if [ -z "$BUILD" ] || [ "$BUILD" = "null" ]; then
  echo "No stable build found for $VERSION"
  exit 1
fi

echo "Selected build: $BUILD"

# 4. Get file info
FILE=$(echo "$BUILDS_JSON" \
  | jq -r --arg id "$BUILD" '.[] | select(.id == ($id | tonumber)) | .downloads.application.name')

DOWNLOAD_URL=$(echo "$BUILDS_JSON" \
  | jq -r --arg id "$BUILD" '.[] | select(.id == ($id | tonumber)) | .downloads.application.url')

# 5. Download server jar
echo "Downloading: $FILE"

curl -L -H "User-Agent: $USER_AGENT" \
  -o server.jar "$DOWNLOAD_URL"

echo "Paper installed successfully."