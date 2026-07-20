#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]
then
  echo "usage: $0 BOTTLE_DIR VERSION ROOT_URL" >&2
  exit 1
fi

readonly BOTTLE_DIR="$1"
readonly VERSION="${2#v}"
readonly ROOT_URL="$3"
readonly FORMULA="tencentcloudagentruntime/tap/agr-cli"
readonly EXPECTED_TAGS="arm64_linux arm64_tahoe sequoia x86_64_linux"

fail() {
  echo "invalid bottle artifacts: $*" >&2
  exit 1
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1
  then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

[[ -d "${BOTTLE_DIR}" ]] || fail "missing directory ${BOTTLE_DIR}"

json_count="$(find "${BOTTLE_DIR}" -maxdepth 1 -type f -name '*.bottle.json' | wc -l | tr -d ' ')"
bottle_count="$(find "${BOTTLE_DIR}" -maxdepth 1 -type f -name '*.bottle.tar.gz' | wc -l | tr -d ' ')"
[[ "${json_count}" == 4 ]] || fail "expected 4 JSON files, found ${json_count}"
[[ "${bottle_count}" == 4 ]] || fail "expected 4 bottle archives, found ${bottle_count}"

tags_file="$(mktemp)"
trap 'rm -f "${tags_file}"' EXIT

for metadata in "${BOTTLE_DIR}"/*.bottle.json
do
  if ! jq --exit-status \
     --arg formula "${FORMULA}" \
     --arg version "${VERSION}" \
     --arg root_url "${ROOT_URL}" \
        'keys == [$formula] and
     .[$formula].formula.pkg_version == $version and
     .[$formula].bottle.root_url == $root_url and
     .[$formula].bottle.rebuild == 0 and
     (.[$formula].bottle.tags | length) == 1' \
     "${metadata}" >/dev/null
  then
    fail "metadata mismatch in $(basename "${metadata}")"
  fi

  tag="$(jq -r --arg formula "${FORMULA}" '.[$formula].bottle.tags | keys[0]' "${metadata}")"
  local_filename="$(jq -r --arg formula "${FORMULA}" --arg tag "${tag}" \
    '.[$formula].bottle.tags[$tag].local_filename' "${metadata}")"
  expected_filename="agr-cli--${VERSION}.${tag}.bottle.tar.gz"
  [[ "${local_filename}" == "${expected_filename}" ]] ||
    fail "unexpected local filename ${local_filename} for ${tag}"

  archive="${BOTTLE_DIR}/${local_filename}"
  [[ -f "${archive}" ]] || fail "missing archive ${local_filename}"

  expected_checksum="$(jq -r --arg formula "${FORMULA}" --arg tag "${tag}" \
    '.[$formula].bottle.tags[$tag].sha256' "${metadata}")"
  actual_checksum="$(sha256_file "${archive}")"
  [[ "${actual_checksum}" == "${expected_checksum}" ]] ||
    fail "checksum mismatch for ${local_filename}"

  printf '%s\n' "${tag}" >>"${tags_file}"
done

actual_tags="$(sort "${tags_file}" | tr '\n' ' ' | sed 's/ $//')"
[[ "${actual_tags}" == "${EXPECTED_TAGS}" ]] ||
  fail "expected tags '${EXPECTED_TAGS}', found '${actual_tags}'"

echo "Bottle artifacts are valid for agr-cli ${VERSION}"
