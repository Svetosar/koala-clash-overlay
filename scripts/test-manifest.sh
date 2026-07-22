#!/bin/sh
set -e

EBUILD_DIR="net-proxy/koala-clash"
MANIFEST="$EBUILD_DIR/Manifest"

echo "=== Testing Manifest ==="
[ -f "$MANIFEST" ] || { echo "FAIL: Manifest not found"; exit 1; }
echo "OK: Manifest exists"

DIST_LINE=$(grep "^DIST " "$MANIFEST")
ARCHIVE=$(echo "$DIST_LINE" | awk '{print $2}')
[ -n "$ARCHIVE" ] || { echo "FAIL: no DIST entry"; exit 1; }
echo "DIST: $ARCHIVE"

SHA256=$(echo "$DIST_LINE" | grep -o 'SHA256 [a-f0-9]*' | cut -d' ' -f2)
[ -n "$SHA256" ] || { echo "FAIL: SHA256 missing for $ARCHIVE"; exit 1; }
echo "OK: SHA256=$SHA256"

BLAKE2B=$(echo "$DIST_LINE" | grep -o 'BLAKE2B [a-f0-9]*' | cut -d' ' -f2)
[ -n "$BLAKE2B" ] || { echo "FAIL: BLAKE2B missing for $ARCHIVE"; exit 1; }
echo "OK: BLAKE2B present"

SHA512=$(echo "$DIST_LINE" | grep -o 'SHA512 [a-f0-9]*' | cut -d' ' -f2)
[ -n "$SHA512" ] || { echo "FAIL: SHA512 missing for $ARCHIVE"; exit 1; }
echo "OK: SHA512 present"

for eb in "$EBUILD_DIR"/koala-clash-*.ebuild; do
  name=$(basename "$eb")
  grep -q "EBUILD $name " "$MANIFEST" || { echo "FAIL: $name not in Manifest"; exit 1; }
  echo "OK: $name in Manifest"
done

grep -q "^MISC " "$MANIFEST" || { echo "FAIL: MISC entry missing"; exit 1; }
echo "OK: MISC metadata.xml in Manifest"

echo "=== MANIFEST VALID ==="
