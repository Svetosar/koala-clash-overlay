#!/bin/sh
set -e

REPO="coolcoala/koala-clash"
EBUILD_DIR="net-proxy/koala-clash"

if [ -n "$LATEST" ]; then
  echo "Using forced version: $LATEST"
  LATEST_FORCED="1"
else
  AUTH=""
  if [ -n "$GH_TOKEN" ]; then
    AUTH="Authorization: Bearer $GH_TOKEN"
  fi

  if [ -n "$AUTH" ]; then
    LATEST=$(curl -s -H "$AUTH" "https://api.github.com/repos/$REPO/releases/latest" \
      | jq -r '.tag_name | sub("^v"; "")')
  else
    LATEST=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
      | jq -r '.tag_name | sub("^v"; "")')
  fi
fi

if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
  echo "ERROR: failed to fetch latest version"
  exit 1
fi

CURRENT=$(ls "$EBUILD_DIR"/koala-clash-*.ebuild | sort -V | tail -1 | xargs basename | sed 's/koala-clash-//; s/\.ebuild//')

echo "current=$CURRENT latest=$LATEST"

if [ -n "$LATEST_FORCED" ] && [ "$LATEST" = "$CURRENT" ]; then
  echo "needs_update=true" >> $GITHUB_OUTPUT
  echo "version=$LATEST" >> $GITHUB_OUTPUT
  echo "Forced re-bump of $LATEST"
  exit 0
fi

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
