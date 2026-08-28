#!/bin/bash
# Smoke test: build the newest koala-clash ebuild inside a Gentoo container.
# Runs on the GitHub Actions runner (ubuntu-latest has docker); also local if docker present.
set -euo pipefail
cd "$(dirname "$0")/.."

EBUILD="$(ls net-proxy/koala-clash/koala-clash-*.ebuild | sort -V | tail -1 | xargs basename)"
[ -n "$EBUILD" ] || { echo "no ebuild found"; exit 1; }
echo "== smoke: ${EBUILD} =="

command -v docker >/dev/null || { echo "docker not available"; exit 1; }

docker run --rm \
	-v "$PWD":/koala-overlay:ro \
	gentoo/portage:latest \
	bash -c '
		set -euo pipefail
		REPO=/var/db/repos/koala-clash-overlay
		mkdir -p "$REPO"
		cp -r /koala-overlay/net-proxy "$REPO"/
		cp -r /koala-overlay/metadata "$REPO"/
		cp -r /koala-overlay/profiles "$REPO"/

		EBUILD=$(ls "$REPO"/net-proxy/koala-clash/koala-clash-*.ebuild | sort -V | tail -1)
		echo "== testing $(basename "$EBUILD") =="

		# fetch distfile and verify it against Manifest DIST hashes
		ebuild "$EBUILD" fetch

		# regenerate Manifest inside the container: proves our hashes are identical to portage' ones
		ebuild "$EBUILD" manifest

		# unpack + default_src_prepare: proves the tarball really opens and ebuild phases run
		ebuild "$EBUILD" prepare

		echo "SMOKE OK"
	'

echo "smoke passed for ${EBUILD}"