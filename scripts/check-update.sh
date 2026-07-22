#!/bin/sh
set -e

REPO="coolcoala/koala-clash"
EBUILD_DIR="net-proxy/koala-clash"

if [ -n "$LATEST" ]; then
  echo "Using forced version: $LATEST"
else
  LATEST=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
    | jq -r '.tag_name | sub("^v"; "")')
fi

if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  echo "ERROR: failed to fetch latest version"
  exit 1
fi

CURRENT=$(basename "$EBUILD_DIR"/koala-clash-*.ebuild .ebuild | sed 's/koala-clash-//')

echo "current=$CURRENT latest=$LATEST"

if [ "$LATEST" != "$CURRENT" ]; then
  echo "needs_update=true" >> $GITHUB_OUTPUT
  echo "version=$LATEST" >> $GITHUB_OUTPUT
  echo "New version: $LATEST"
  exit 0
else
  echo "needs_update=false" >> $GITHUB_OUTPUT
  echo "Up to date."
  exit 0
fi
