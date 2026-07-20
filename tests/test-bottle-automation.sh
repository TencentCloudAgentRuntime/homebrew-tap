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
  grep -Fq -- "$text" "$file" || fail "$file does not contain: $text"
}

assert_not_contains() {
  local file="$1"
  local text="$2"
  if grep -Fq -- "$text" "$file"; then
    fail "$file unexpectedly contains: $text"
  fi
}

test_update_script_removes_stale_bottle() {
  local test_dir
  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  local formula_path="$test_dir/agr-cli.rb"
  ruby - "$ROOT_DIR/Formula/agr-cli.rb" "$formula_path" <<'RUBY'
source_path, target_path = ARGV
formula = File.read(source_path)
bottle = <<BOTTLE

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/homebrew-tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "#{'a' * 64}"
  end
BOTTLE
formula.sub!(/^  license .*$/, "\\0#{bottle}") or abort "license declaration not found"
File.write(target_path, formula)
RUBY

  local fixtures="$test_dir/fixtures"
  local fake_bin="$test_dir/bin"
  mkdir -p "$fixtures" "$fake_bin"

  local platform artifact checksum
  : > "$fixtures/checksums.txt"
  for platform in darwin-arm64 darwin-amd64 linux-arm64 linux-amd64; do
    artifact="agr-0.6.4-${platform}.tar.gz"
    printf 'fixture for %s\n' "$platform" > "$fixtures/$artifact"
    if command -v sha256sum >/dev/null 2>&1; then
      checksum="$(sha256sum "$fixtures/$artifact" | awk '{ print $1 }')"
    else
      checksum="$(shasum -a 256 "$fixtures/$artifact" | awk '{ print $1 }')"
    fi
    printf '%s  %s\n' "$checksum" "$artifact" >> "$fixtures/checksums.txt"
  done

  cat > "$fake_bin/curl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

url=""
output=""
while (($#)); do
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
  chmod +x "$fake_bin/curl"

  PATH="$fake_bin:$PATH" \
    FIXTURE_DIR="$fixtures" \
    FORMULA_PATH="$formula_path" \
    "$ROOT_DIR/scripts/update-agr-cli.sh" v0.6.4

  assert_contains "$formula_path" '  version "0.6.4"'
  assert_contains "$formula_path" '/v0.6.4/agr-0.6.4-darwin-arm64.tar.gz"'
  assert_not_contains "$formula_path" "bottle do"
}

test_bottle_workflows() {
  local tests_workflow="$ROOT_DIR/.github/workflows/tests.yml"
  local publish_workflow="$ROOT_DIR/.github/workflows/publish.yml"
  local update_workflow="$ROOT_DIR/.github/workflows/update-agr-cli.yml"
  local readme="$ROOT_DIR/README.md"

  assert_file "$tests_workflow"
  assert_not_file "$publish_workflow"
  assert_contains "$tests_workflow" "tests/test-bottle-automation.sh all"
  assert_contains "$update_workflow" "gh api repos/TencentCloudAgentRuntime/ags-cli/releases/tags/\"\$VERSION\""
  assert_contains "$update_workflow" "brew test-bot --only-formulae --testing-formulae=agr-cli --root-url=https://ghcr.io/v2/tencentcloudagentruntime/homebrew-tap"
  assert_contains "$update_workflow" "path: '*.bottle.*'"
  assert_contains "$update_workflow" "actions/download-artifact@"
  assert_contains "$update_workflow" "brew bottle --merge --write --no-commit"
  assert_contains "$update_workflow" "brew pr-upload --upload-only"
  assert_contains "$update_workflow" "packages: write"
  assert_contains "$update_workflow" "actions/create-github-app-token@"
  assert_contains "$update_workflow" "permission-contents: write"
  assert_contains "$update_workflow" "HOMEBREW_TAP_APP_PRIVATE_KEY is not configured"
  assert_contains "$update_workflow" "branch: main"
  assert_contains "$update_workflow" "brew test-bot --only-bottles-fetch --testing-formulae=agr-cli"
  assert_not_contains "$update_workflow" "pull-requests: write"
  assert_not_contains "$update_workflow" "gh pr create"
  assert_not_contains "$update_workflow" "brew pr-pull"
  assert_contains "$readme" "HOMEBREW_TAP_APP_ID"
  assert_contains "$readme" "directly to \`main\`"
  assert_not_contains "$readme" "brew pr-pull"
}

case "${1:-all}" in
  script)
    test_update_script_removes_stale_bottle
    ;;
  workflows)
    test_bottle_workflows
    ;;
  all)
    test_update_script_removes_stale_bottle
    test_bottle_workflows
    ;;
  *)
    fail "usage: $0 [script|workflows|all]"
    ;;
esac

echo "Bottle automation tests passed"
