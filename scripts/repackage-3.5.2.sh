#!/usr/bin/env bash
# Records and verifies how the single-xcframework zips used by Package.swift were made for 3.5.2.
#
# SwiftPM needs one xcframework per binary-target zip. Five 3.5.2 release zips already hold one
# xcframework and are used unchanged. The xcframeworks below come from release zips that hold
# several, so they were extracted (unchanged) and zipped one per file with
# `ditto -c -k --keepParent`, then uploaded to the 3.5.2 release of msp-ios-sdk-public.
#
# Zipping is not byte-reproducible (timestamps), so the uploaded zips are the source of truth and
# must never be replaced. By default this script only VERIFIES: it downloads the original release
# zips and the uploaded zips and checks that each uploaded xcframework is byte-identical to the
# one in the original release zip. `--build <dir>` recreates the zips in <dir> (for a new version
# or if the assets were ever lost); their checksums will differ from Package.swift.
#
# Usage: scripts/repackage-3.5.2.sh            # verify
#        scripts/repackage-3.5.2.sh --build DIR  # recreate zips into DIR
set -euo pipefail

VERSION="3.5.2"
BASE_URL="https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/${VERSION}"

# <xcframework name> <source release zip> <path inside the source zip>
# MSPiOSCore comes from MSPSharedLibraries-3.5.2.zip, NOT MSPiOSCore-3.5.2.zip: the two copies
# have identical binaries but different headers, and the MSPSharedLibraries copy is the one the
# verified local package (msp-sdk-demo-ios, branch spm_3.5.2) uses.
SOURCES="
MSPiOSCore MSPSharedLibraries Binary/MSPiOSCore.xcframework
MSPSharedLibraries MSPSharedLibraries Binary/MSPSharedLibraries.xcframework
PrebidMobile MSPSharedLibraries ThirdParty/PrebidMobile/PrebidMobile.xcframework
OMSDK_Newsbreak1 MSPSharedLibraries ThirdParty/OMSDK/OMSDK_Newsbreak1.xcframework
NovaCore MSPNovaAdapter Binary/NovaCore.xcframework
MSPNovaAdapter MSPNovaAdapter Binary/MSPNovaAdapter.xcframework
"

MODE="verify"
OUT_DIR=""
if [ "${1:-}" = "--build" ]; then
  MODE="build"
  OUT_DIR="${2:?usage: $0 --build <dir>}"
  mkdir -p "${OUT_DIR}"
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

tree_hash() {
  (cd "$1" && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256 | shasum -a 256 | cut -d' ' -f1)
}

for source_zip in MSPSharedLibraries MSPNovaAdapter; do
  curl -fsSL -o "${WORK_DIR}/${source_zip}.zip" "${BASE_URL}/${source_zip}-${VERSION}.zip"
  mkdir -p "${WORK_DIR}/src/${source_zip}"
  unzip -q "${WORK_DIR}/${source_zip}.zip" -d "${WORK_DIR}/src/${source_zip}"
done

status=0
echo "${SOURCES}" | while read -r name source_zip inner_path; do
  [ -n "${name}" ] || continue
  src="${WORK_DIR}/src/${source_zip}/${inner_path}"
  zip_name="${name}.xcframework-${VERSION}.zip"

  if [ "${MODE}" = "build" ]; then
    (cd "$(dirname "${src}")" && ditto -c -k --keepParent --norsrc "${name}.xcframework" "${OUT_DIR}/${zip_name}")
    echo "built ${zip_name}  checksum $(shasum -a 256 "${OUT_DIR}/${zip_name}" | cut -d' ' -f1)"
    continue
  fi

  curl -fsSL -o "${WORK_DIR}/${zip_name}" "${BASE_URL}/${zip_name}"
  mkdir -p "${WORK_DIR}/uploaded/${name}"
  unzip -q "${WORK_DIR}/${zip_name}" -d "${WORK_DIR}/uploaded/${name}"
  if [ "$(tree_hash "${src}")" = "$(tree_hash "${WORK_DIR}/uploaded/${name}/${name}.xcframework")" ]; then
    echo "OK   ${zip_name}  checksum $(shasum -a 256 "${WORK_DIR}/${zip_name}" | cut -d' ' -f1)"
  else
    echo "FAIL ${zip_name}: contents differ from ${source_zip}-${VERSION}.zip/${inner_path}" >&2
    exit 1  # leaves the piped while-loop subshell; caught by `|| status=1` below
  fi
done || status=1

exit "${status}"
