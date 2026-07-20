#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY="TencentCloudAgentRuntime/ags-cli"
readonly FORMULA_PATH="${FORMULA_PATH:-Formula/agr-cli.rb}"
readonly TAG="${1:-}"

if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "usage: $0 vX.Y.Z" >&2
  exit 1
fi

if [[ ! -f "$FORMULA_PATH" ]]; then
  echo "formula not found: $FORMULA_PATH" >&2
  exit 1
fi

readonly VERSION="${TAG#v}"
readonly BASE_URL="https://github.com/${REPOSITORY}/releases/download/${TAG}"
WORK_DIR="$(mktemp -d)"
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT

curl --fail --location --retry 3 --silent --show-error \
  "${BASE_URL}/checksums.txt" \
  --output "${WORK_DIR}/checksums.txt"

declare -a PLATFORMS=(
  "darwin-arm64"
  "darwin-amd64"
  "linux-arm64"
  "linux-amd64"
)

declare -a CHECKSUMS=()
for platform in "${PLATFORMS[@]}"; do
  artifact="agr-${VERSION}-${platform}.tar.gz"
  checksum="$(awk -v name="$artifact" '$2 == name { print $1 }' "${WORK_DIR}/checksums.txt")"

  if [[ ! "$checksum" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "missing or invalid checksum for ${artifact}" >&2
    exit 1
  fi

  curl --fail --location --retry 3 --silent --show-error \
    "${BASE_URL}/${artifact}" \
    --output "${WORK_DIR}/${artifact}"

  if command -v sha256sum >/dev/null 2>&1; then
    actual_checksum="$(sha256sum "${WORK_DIR}/${artifact}" | awk '{ print $1 }')"
  else
    actual_checksum="$(shasum -a 256 "${WORK_DIR}/${artifact}" | awk '{ print $1 }')"
  fi

  if [[ "$actual_checksum" != "$checksum" ]]; then
    echo "checksum mismatch for ${artifact}" >&2
    exit 1
  fi

  CHECKSUMS+=("$(printf '%s' "$checksum" | tr '[:upper:]' '[:lower:]')")
done

ruby - "$FORMULA_PATH" "$VERSION" "${CHECKSUMS[@]}" <<'RUBY'
formula_path, version, darwin_arm64, darwin_amd64, linux_arm64, linux_amd64 = ARGV
formula = File.read(formula_path)

bottle_pattern = /^  bottle do\n.*?^  end\n\n?/m
bottle_blocks = formula.scan(bottle_pattern).length
abort "expected at most one Formula bottle block, found #{bottle_blocks}" if bottle_blocks > 1
formula.sub!(bottle_pattern, "")

replacements = {
  /^  version ".*"$/ => %(  version "#{version}"),
  %r{^      url ".*/agr-.*-darwin-arm64\.tar\.gz"$} => %(      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v#{version}/agr-#{version}-darwin-arm64.tar.gz"),
  %r{^      url ".*/agr-.*-darwin-amd64\.tar\.gz"$} => %(      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v#{version}/agr-#{version}-darwin-amd64.tar.gz"),
  %r{^      url ".*/agr-.*-linux-arm64\.tar\.gz"$} => %(      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v#{version}/agr-#{version}-linux-arm64.tar.gz"),
  %r{^      url ".*/agr-.*-linux-amd64\.tar\.gz"$} => %(      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v#{version}/agr-#{version}-linux-amd64.tar.gz"),
}

replacements.each do |pattern, replacement|
  matches = formula.scan(pattern).length
  abort "expected one Formula match for #{pattern.inspect}, found #{matches}" unless matches == 1
  formula.sub!(pattern, replacement)
end

checksums = [darwin_arm64, darwin_amd64, linux_arm64, linux_amd64]
checksum_index = 0
formula.gsub!(/^      sha256 "[0-9a-fA-F]{64}"$/) do
  checksum = checksums.fetch(checksum_index)
  checksum_index += 1
  %(      sha256 "#{checksum}")
end
abort "expected four Formula checksums, found #{checksum_index}" unless checksum_index == 4

File.write(formula_path, formula)
RUBY

echo "Updated ${FORMULA_PATH} to ${TAG}"
