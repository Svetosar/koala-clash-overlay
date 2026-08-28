#!/bin/bash
# Bump net-proxy/koala-clash to the latest upstream release.
# Runs identically on a GitHub Actions runner and locally.
#
# Env:
#   LATEST   force a specific version (default: upstream latest from api)
#   FORCE=1  re-bump even if LATEST == current, or start from scratch anyway
#   GH_TOKEN authenticated token (also written to $GITHUB_OUTPUT on runners)
#   UPSTREAM_REPO / EBUILD_DIR / ASSET overrides (defaults below)
set -euo pipefail

UPSTREAM_REPO="${UPSTREAM_REPO:-coolcoala/koala-clash}"
EBUILD_DIR="${EBUILD_DIR:-net-proxy/koala-clash}"
ASSET="${ASSET:-Koala.Clash_x64.pkg.tar.xz}"
API="https://api.github.com/repos/${UPSTREAM_REPO}"

cd "$(dirname "$0")/.."

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

AUTH=()
[ -n "${GH_TOKEN:-}" ] && AUTH=(-H "Authorization: Bearer ${GH_TOKEN}")

emit() {
	# set step outputs when running inside GitHub Actions
	if [ -n "${GITHUB_OUTPUT:-}" ]; then
		printf '%s\n' "$*" >> "$GITHUB_OUTPUT"
	fi
}

json_get() {
	# json_get <field> <json-file> [fallback]
	python3 "$1" "$2" "${3:-}" <<'PY' || die "json parse failed: $1"
import json,sys
field, path, fallback = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    d = json.load(open(path))
except Exception:
    print(fallback); raise
print(d.get(field, fallback))
PY
}

asset_url_of() {
	# asset_url_of <json-file> <asset-name>
	python3 - "$1" "$2" <<'PY' || die "json parse failed: assets"
import json,sys
d = json.load(open(sys.argv[1]))
for a in d.get("assets", []):
    if a.get("name") == sys.argv[2]:
        print(a.get("browser_download_url", ""))
        break
PY
}

# --- resolve target version -------------------------------------------------
LATEST="${LATEST:-}"
if [ -z "$LATEST" ]; then
	curl -fsSL "${AUTH[@]}" "${API}/releases/latest" -o "${TMP}/latest.json" || die "failed to fetch latest release"
	tag="$(json_get tag_name "${TMP}/latest.json"| sed 's/^v//')"
	[ -n "$tag" ] || die "could not resolve latest release (empty tag_name)"
	LATEST="${tag#v}"
fi

CURRENT="$(ls "${EBUILD_DIR}"/koala-clash-*.ebuild | sort -V | tail -1 | xargs basename \
	| sed 's/^koala-clash-//; s/\.ebuild$//')"
log "current=${CURRENT} latest=${LATEST}"

if [ "${LATEST}" = "${CURRENT}" ] && [ -z "${FORCE:-}" ]; then
	log "up-to-date (nothing to do)"
	emit changed=false
	emit version="${LATEST}"
	exit 0
fi

# --- resolve asset URL (tags have NO "v" prefix upstream) -------------------
curl -fsSL "${AUTH[@]}" "${API}/releases/tags/${LATEST}" -o "${TMP}/release.json" \
	|| die "failed to fetch release ${LATEST}"
asset_url="$(asset_url_of "${TMP}/release.json" "$ASSET")"
[ -n "$asset_url" ] || die "asset '${ASSET}' not found in release ${LATEST}"

log "fetching ${asset_url}"
curl -fsSL "${AUTH[@]}" -o "${TMP}/${ASSET}" "$asset_url" || die "download failed"

SIZE="$(stat -c %s "${TMP}/${ASSET}")"
SHA256="$(sha256sum "${TMP}/${ASSET}" | awk '{print $1}')"
SHA512="$(sha512sum "${TMP}/${ASSET}" | awk '{print $1}')"
BLAKE2B="$(openssl dgst -blake2b512 "${TMP}/${ASSET}" | awk '{print $NF}')"
log "digests: size=${SIZE} sha256=${SHA256}"

# --- archive layout must match src_install expectations ---------------------
tar -tJf "${TMP}/${ASSET}" > "${TMP}/list" || die "cannot read ${ASSET}"
REQUIRED=(
	"opt/Koala.Clash/koala-clash"
	"opt/Koala.Clash/chrome-sandbox"
	"opt/Koala.Clash/chrome_crashpad_handler"
	"opt/Koala.Clash/libEGL.so"
	"opt/Koala.Clash/libGLESv2.so"
	"opt/Koala.Clash/libffmpeg.so"
	"opt/Koala.Clash/libvk_swiftshader.so"
	"opt/Koala.Clash/libvulkan.so.1"
	"opt/Koala.Clash/resources/sidecar/mihomo"
	"opt/Koala.Clash/resources/sidecar/mihomo-alpha"
	"opt/Koala.Clash/resources/files/sparkle-service"
	"opt/Koala.Clash/resources/apparmor-profile"
	"usr/share/applications/koala-clash.desktop"
	"usr/share/icons/hicolor/512x512/apps/koala-clash.png"
)
for p in "${REQUIRED[@]}"; do
	grep -qxF "$p" "${TMP}/list" || {
		log "archive layout changed: missing '${p}'. new entries:"
		sed -n '1,40p' "${TMP}/list"
		die "structure check failed"
	}
done
log "archive layout OK (${#REQUIRED[@]} paths)"

# --- new ebuild (template = newest existing) --------------------------------
TEMPLATE="${EBUILD_DIR}/koala-clash-${CURRENT}.ebuild"
[ -f "$TEMPLATE" ] || die "template ebuild not found: ${TEMPLATE}"
NEW="${EBUILD_DIR}/koala-clash-${LATEST}.ebuild"
if [ -f "$NEW" ]; then
	log "WARNING: ${NEW} already exists, overwriting"
fi
cp "$TEMPLATE" "$NEW"
log "created ${NEW}"

# --- Manifest: DIST + ALL ebuilds + MISC (metadata.xml, NOT EBUILD) ---------
{
	printf 'DIST %s %s BLAKE2B %s SHA512 %s SHA256 %s\n' \
		"$ASSET" "$SIZE" "$BLAKE2B" "$SHA512" "$SHA256"
	for eb in "${EBUILD_DIR}"/koala-clash-*.ebuild; do
		printf 'EBUILD %s %s BLAKE2B %s SHA512 %s SHA256 %s\n' \
			"$(basename "$eb")" "$(stat -c %s "$eb")" \
			"$(openssl dgst -blake2b512 "$eb" | awk '{print $NF}')" \
			"$(sha512sum "$eb" | awk '{print $1}')" \
			"$(sha256sum "$eb" | awk '{print $1}')"
	done
	meta="${EBUILD_DIR}/metadata.xml"
	printf 'MISC %s %s BLAKE2B %s SHA512 %s SHA256 %s\n' \
		"$(basename "$meta")" "$(stat -c %s "$meta")" \
		"$(openssl dgst -blake2b512 "$meta" | awk '{print $NF}')" \
		"$(sha512sum "$meta" | awk '{print $1}')" \
		"$(sha256sum "$meta" | awk '{print $1}')"
} > "${EBUILD_DIR}/Manifest"
log "Manifest regenerated for ${LATEST}"

# --- self-check -------------------------------------------------------------
bash -n "$NEW"
scripts/test-ebuild.sh
scripts/test-manifest.sh
grep -q "SHA256 ${SHA256}" "${EBUILD_DIR}/Manifest" || die "Manifest SHA256 mismatch"

log "OK: koala-clash ${CURRENT} -> ${LATEST} ready"
emit changed=true
emit version="${LATEST}"