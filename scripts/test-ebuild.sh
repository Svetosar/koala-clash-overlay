#!/bin/sh
set -e

EBUILD_DIR="net-proxy/koala-clash"

EBUILD=$(ls "$EBUILD_DIR"/koala-clash-*.ebuild | sort -V | tail -1)
echo "=== Testing: $EBUILD ==="

bash -n "$EBUILD" || { echo "FAIL: bash syntax"; exit 1; }
echo "OK: bash syntax"

for key in EAPI DESCRIPTION HOMEPAGE SRC_URI LICENSE SLOT KEYWORDS RESTRICT RDEPEND; do
  grep -q "^${key}=" "$EBUILD" && echo "OK: $key" || { echo "FAIL: $key missing"; exit 1; }
done

grep -q 'KEYWORDS="~amd64"' "$EBUILD" || { echo "FAIL: KEYWORDS missing ~amd64"; exit 1; }
echo "OK: KEYWORDS=~amd64"

grep -q 'RESTRICT=".*test.*"' "$EBUILD" || { echo "FAIL: RESTRICT missing test"; exit 1; }
echo "OK: RESTRICT has test"

grep -q 'RESTRICT=".*strip.*"' "$EBUILD" || { echo "FAIL: RESTRICT missing strip"; exit 1; }
echo "OK: RESTRICT has strip"

grep -q 'BDEPEND.*xz-utils' "$EBUILD" || { echo "FAIL: BDEPEND missing xz-utils"; exit 1; }
echo "OK: BDEPEND has xz-utils"

grep -q 'fperms 4755.*mihomo\b' "$EBUILD" || { echo "FAIL: SUID missing on mihomo"; exit 1; }
echo "OK: SUID on mihomo"

grep -q 'fperms 4755.*chrome-sandbox' "$EBUILD" || { echo "FAIL: SUID missing on chrome-sandbox"; exit 1; }
echo "OK: SUID on chrome-sandbox"

grep -q 'dosym.*koala-clash.*/usr/bin' "$EBUILD" || { echo "FAIL: dosym missing"; exit 1; }
echo "OK: dosym present"

echo "=== EBUILD CHECKS PASSED ==="
