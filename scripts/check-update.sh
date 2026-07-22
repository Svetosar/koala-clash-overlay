#!/bin/sh

set -e

REPO="coolcoala/koala-clash"
EBUILD_DIR="net-proxy/koala-clash"

LATEST=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name | sub("^v"; "")')
if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  echo "ERROR: Failed to fetch latest version from GitHub"
  exit 1
fi

CURRENT=$(basename "$EBUILD_DIR"/koala-clash-*.ebuild .ebuild | sed 's/koala-clash-//')

echo "Current: $CURRENT  Latest: $LATEST"

if [ "$LATEST" != "$CURRENT" ]; then
  echo "New version available: $LATEST"
  exit 0
else
  echo "Up to date."
  exit 1
fi
