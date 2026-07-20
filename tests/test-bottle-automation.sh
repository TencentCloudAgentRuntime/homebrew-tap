#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT_DIR

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_not_file() {
  [[ ! -e "$1" ]] || fail "unexpected file: $1"
}

assert_contains() {
  local file="$1"
  local text="$2"
  grep -Fq -- "${text}" "${file}" || fail "${file} does not contain: ${text}"
}

assert_not_contains() {
  local file="$1"
  local text="$2"
  if grep -Fq -- "${text}" "${file}"
  then
    fail "${file} unexpectedly contains: ${text}"
  fi
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1
  then
    sha256sum "$1" | awk '{ print $1 }'
  else
    shasum -a 256 "$1" | awk '{ print $1 }'
  fi
}

create_bottle_fixtures() {
  local bottle_dir="$1"
  local version="$2"
  local root_url="$3"
  local tag filename checksum

  mkdir -p "${bottle_dir}"
  for tag in arm64_tahoe sequoia arm64_linux x86_64_linux
  do
    filename="agr-cli--${version}.${tag}.bottle.tar.gz"
    printf 'fixture for %s\n' "${tag}" >"${bottle_dir}/${filename}"
    checksum="$(sha256_file "${bottle_dir}/${filename}")"
    jq -n \
      --arg version "${version}" \
      --arg root_url "${root_url}" \
      --arg tag "${tag}" \
      --arg filename "${filename}" \
      --arg checksum "${checksum}" \
      '{
        "tencentcloudagentruntime/tap/agr-cli": {
          formula: { pkg_version: $version },
          bottle: {
            root_url: $root_url,
            rebuild: 0,
            tags: { ($tag): { filename: $filename, local_filename: $filename, sha256: $checksum } }
          }
        }
      }' >"${bottle_dir}/agr-cli--${version}.${tag}.bottle.json"
  done
}

test_update_script_removes_stale_bottle() {
  local test_dir
  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  local formula_path="${test_dir}/agr-cli.rb"
  brew ruby - "${ROOT_DIR}/Formula/agr-cli.rb" "${formula_path}" <<'RUBY'
source_path, target_path = ARGV
formula = File.read(source_path)
bottle = <<BOTTLE

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "#{'a' * 64}"
  end
BOTTLE
formula.sub!(/^  license .*$/, "\\0#{bottle}") or abort "license declaration not found"
File.write(target_path, formula)
RUBY

  local fixtures="${test_dir}/fixtures"
  local fake_bin="${test_dir}/bin"
  mkdir -p "${fixtures}" "${fake_bin}"

  local platform artifact checksum
  : >"${fixtures}/checksums.txt"
  for platform in darwin-arm64 darwin-amd64 linux-arm64 linux-amd64
  do
    artifact="agr-0.6.4-${platform}.tar.gz"
    printf 'fixture for %s\n' "${platform}" >"${fixtures}/${artifact}"
    if command -v sha256sum >/dev/null 2>&1
    then
      checksum="$(sha256sum "${fixtures}/${artifact}" | awk '{ print $1 }')"
    else
      checksum="$(shasum -a 256 "${fixtures}/${artifact}" | awk '{ print $1 }')"
    fi
    printf '%s  %s\n' "${checksum}" "${artifact}" >>"${fixtures}/checksums.txt"
  done

  cat >"${fake_bin}/curl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

url=""
output=""
while (($#))
do
  case "$1" in
    --output)
      output="$2"
      shift 2
      ;;
    --*)
      shift
      ;;
    *)
      url="$1"
      shift
      ;;
  esac
done

cp "$FIXTURE_DIR/$(basename "$url")" "$output"
SH
  cat >"${fake_bin}/ruby" <<'SH'
#!/usr/bin/env bash
echo "standalone ruby must not be used" >&2
exit 99
SH
  chmod +x "${fake_bin}/curl" "${fake_bin}/ruby"

  PATH="${fake_bin}:${PATH}" \
    FIXTURE_DIR="${fixtures}" \
    FORMULA_PATH="${formula_path}" \
    "${ROOT_DIR}/scripts/update-agr-cli.sh" v0.6.4

  assert_contains "${formula_path}" '  version "0.6.4"'
  assert_contains "${formula_path}" '/v0.6.4/agr-0.6.4-darwin-arm64.tar.gz"'
  assert_not_contains "${formula_path}" "bottle do"
}

test_bottle_workflows() {
  local tests_workflow="${ROOT_DIR}/.github/workflows/tests.yml"
  local publish_workflow="${ROOT_DIR}/.github/workflows/publish.yml"
  local update_workflow="${ROOT_DIR}/.github/workflows/update-agr-cli.yml"
  local actionlint_config="${ROOT_DIR}/.github/actionlint.yaml"
  local readme="${ROOT_DIR}/README.md"

  assert_file "${tests_workflow}"
  assert_not_file "${publish_workflow}"
  assert_file "${actionlint_config}"
  assert_contains "${actionlint_config}" "HOMEBREW_TAP_APP_ID"
  assert_contains "${tests_workflow}" "tests/test-bottle-automation.sh all"
  assert_contains "${tests_workflow}" "working-directory: \${{ steps.set-up-homebrew.outputs.repository-path }}"
  assert_contains "${tests_workflow}" "path: \${{ steps.set-up-homebrew.outputs.repository-path }}/*.bottle.*"
  assert_contains "${update_workflow}" "gh api repos/TencentCloudAgentRuntime/ags-cli/releases/tags/\"\$VERSION\""
  assert_contains "${update_workflow}" "working-directory: \${{ steps.set-up-homebrew.outputs.repository-path }}"
  assert_contains "${update_workflow}" "changed_files=\"\$(git diff --name-only)\""
  assert_contains "${update_workflow}" "if [[ -n \"\${changed_files}\" && \"\${changed_files}\" != \"Formula/agr-cli.rb\" ]]; then"
  assert_contains "${update_workflow}" "unexpected update scope: \${changed_files}"
  assert_contains "${update_workflow}" "test \"\$(git diff --name-only)\" = \"Formula/agr-cli.rb\""
  assert_contains "${update_workflow}" "BOTTLE_ROOT_URL: https://ghcr.io/v2/tencentcloudagentruntime/tap"
  assert_contains "${update_workflow}" "brew test-bot --only-formulae --keep-old --testing-formulae=agr-cli --root-url=\"\$BOTTLE_ROOT_URL\""
  assert_contains "${update_workflow}" "path: \${{ steps.set-up-homebrew.outputs.repository-path }}/*.bottle.*"
  assert_contains "${update_workflow}" "path: \${{ steps.set-up-homebrew.outputs.repository-path }}/bottles"
  assert_contains "${update_workflow}" "actions/download-artifact@"
  assert_contains "${update_workflow}" "brew bottle --merge --write --no-commit"
  assert_contains "${update_workflow}" "brew pr-upload --upload-only"
  assert_contains "${update_workflow}" "packages: write"
  assert_contains "${update_workflow}" "actions/create-github-app-token@"
  assert_contains "${update_workflow}" "permission-contents: write"
  assert_contains "${update_workflow}" "HOMEBREW_TAP_APP_PRIVATE_KEY is not configured"
  assert_contains "${update_workflow}" "branch: main"
  local push_step
  push_step="$(sed -n '/- name: Push Formula directly to main/,$p' "${update_workflow}")"
  if grep -Fq 'token: ${{ steps.app-token.outputs.token }}' <<<"${push_step}"
  then
    fail "git-try-push must reuse setup-homebrew authentication"
  fi
  assert_contains "${update_workflow}" "brew test-bot --only-bottles-fetch --testing-formulae=agr-cli"
  assert_contains "${update_workflow}" "scripts/validate-bottle-artifacts.sh bottles \"\$VERSION\" \"\$BOTTLE_ROOT_URL\""
  assert_not_contains "${update_workflow}" "Base64-encode GITHUB_TOKEN for bottle verification"
  assert_not_contains "${update_workflow}" "HOMEBREW_DOCKER_REGISTRY_TOKEN: \${{ steps.bottle-fetch-token.outputs.token }}"
  assert_not_contains "${update_workflow}" "pull-requests: write"
  assert_not_contains "${update_workflow}" "gh pr create"
  assert_not_contains "${update_workflow}" "brew pr-pull"
  assert_contains "${readme}" "HOMEBREW_TAP_APP_ID"
  assert_contains "${readme}" "directly to \`main\`"
  assert_contains "${readme}" "make the \`tap/agr-cli\` package public"
  assert_contains "${readme}" "Re-run failed jobs"
  assert_not_contains "${readme}" "brew pr-pull"
}

test_bottle_artifact_validation() {
  local test_dir
  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  local root_url="https://ghcr.io/v2/tencentcloudagentruntime/tap"
  create_bottle_fixtures "${test_dir}" "0.6.4" "${root_url}"

  "${ROOT_DIR}/scripts/validate-bottle-artifacts.sh" \
    "${test_dir}" v0.6.4 "${root_url}"
}

test_bottle_artifact_validation_rejects_bad_checksum() {
  local test_dir
  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  local root_url="https://ghcr.io/v2/tencentcloudagentruntime/tap"
  create_bottle_fixtures "${test_dir}" "0.6.4" "${root_url}"
  printf 'corrupted\n' >"${test_dir}/agr-cli--0.6.4.arm64_tahoe.bottle.tar.gz"

  if "${ROOT_DIR}/scripts/validate-bottle-artifacts.sh" \
     "${test_dir}" v0.6.4 "${root_url}"
  then
    fail "bottle artifact validation accepted a bad checksum"
  fi
}

case "${1:-all}" in
  script)
    test_update_script_removes_stale_bottle
    ;;
  workflows)
    test_bottle_workflows
    ;;
  validation)
    test_bottle_artifact_validation
    test_bottle_artifact_validation_rejects_bad_checksum
    ;;
  all)
    test_update_script_removes_stale_bottle
    test_bottle_workflows
    test_bottle_artifact_validation
    test_bottle_artifact_validation_rejects_bad_checksum
    ;;
  *)
    fail "usage: $0 [script|workflows|all]"
    ;;
esac

echo "Bottle automation tests passed"
