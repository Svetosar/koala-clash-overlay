#!/bin/sh
set -e

REPO="coolcoala/koala-clash"
EBUILD_DIR="net-proxy/koala-clash"
VERSION="${VERSION:-}"

if [ -z "$VERSION" ]; then
  echo "ERROR: VERSION not set"
  exit 1
fi

echo "=== Bumping to $VERSION ==="

ARCHIVE="Koala.Clash_x64.pkg.tar.xz"
URL="https://github.com/$REPO/releases/download/v${VERSION}/${ARCHIVE}"

cd "$EBUILD_DIR"

OLD_EBUILD=$(ls koala-clash-*.ebuild | head -1)

# скачать архив
echo "Downloading $URL"
curl -sLO "$URL" || { echo "Download failed"; exit 1; }

# посчитать хеши
SIZE=$(stat -c%s "$ARCHIVE")
SHA256=$(sha256sum "$ARCHIVE" | cut -d' ' -f1)
BLAKE2B=$(openssl dgst -blake2b512 "$ARCHIVE" | cut -d' ' -f2)
SHA512=$(sha512sum "$ARCHIVE" | cut -d' ' -f1)
echo "archive: $SIZE bytes, sha256=$SHA256"

# создать новый ebuild (копия старого, PV подставится из имени файла)
cp "$OLD_EBUILD" "koala-clash-${VERSION}.ebuild"

# сгенерировать Manifest
{
  echo "DIST ${ARCHIVE} ${SIZE} BLAKE2B ${BLAKE2B} SHA512 ${SHA512} SHA256 ${SHA256}"

  for f in koala-clash-${VERSION}.ebuild metadata.xml; do
    FSIZE=$(stat -c%s "$f")
    FB2=$(openssl dgst -blake2b512 "$f" | cut -d' ' -f2)
    FS512=$(sha512sum "$f" | cut -d' ' -f1)
    FS256=$(sha256sum "$f" | cut -d' ' -f1)
    echo "EBUILD ${f} ${FSIZE} BLAKE2B ${FB2} SHA512 ${FS512} SHA256 ${FS256}"
  done
} > Manifest

rm -f "$ARCHIVE"

echo "=== Done ==="
echo "New:  koala-clash-${VERSION}.ebuild"
echo "Old:  $OLD_EBUILD (kept)"
cat Manifest
