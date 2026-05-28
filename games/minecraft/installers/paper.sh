#!/bin/bash

echo "Installing Paper..."

if [ "$VERSION" = "LATEST" ]; then
  VERSION=$(curl -s https://api.papermc.io/v2/projects/paper \
    | jq -r '.versions[-1]')
fi

BUILD=$(curl -s \
  https://api.papermc.io/v2/projects/paper/versions/${VERSION} \
  | jq '.builds[-1]')

FILE="paper-${VERSION}-${BUILD}.jar"

curl -L -o server.jar \
  https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILE}