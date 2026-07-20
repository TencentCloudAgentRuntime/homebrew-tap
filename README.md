# TencentCloudAgentRuntime Homebrew Tap

Official Homebrew tap for TencentCloudAgentRuntime formulae.

## How do I install these formulae?

Install a formula directly:

```bash
brew install TencentCloudAgentRuntime/tap/agr-cli
```

Or add the tap first and install the formula by name:

```bash
brew tap TencentCloudAgentRuntime/tap
brew install agr-cli
```

Or add it to a `Brewfile`:

```ruby
tap "TencentCloudAgentRuntime/tap"
brew "agr-cli"
```

## Formulae

- [`agr-cli`](https://github.com/TencentCloudAgentRuntime/ags-cli) — CLI for
  Tencent Cloud Agent Runtime. Installs the `agr` command.

## Maintainer release flow

Formal AGR CLI releases dispatch the `Update AGR CLI` workflow. The workflow
validates the formal GitHub Release, updates the Formula, and uses
`brew test-bot` to build and test bottles for the supported macOS and Linux
platforms.

The GitHub App used by the update workflow must be installed on this repository
with **Contents: read and write**. Configure its credentials as below, and
retain **Actions: read and write** for the release workflow that dispatches the
update:

- Repository variable `HOMEBREW_TAP_APP_ID`
- Repository secret `HOMEBREW_TAP_APP_PRIVATE_KEY`

After every platform succeeds, the workflow publishes the bottles to GitHub
Packages, writes the generated `bottle do` block, verifies the published
bottles, and commits the Formula directly to `main`. Protect `main` with a
repository ruleset and grant bypass permission only to this GitHub App so human
changes still require pull requests.

GitHub creates the first Container registry package as private. After the first
upload, a package administrator must make the `tap/agr-cli` package public,
then select **Re-run failed jobs** on that same workflow run. This is a one-time
setup. Bottle verification is intentionally anonymous, so the Formula cannot be
pushed before regular Homebrew users can download the package.

## Documentation

Run `brew help`, read `man brew`, or visit the
[Homebrew documentation](https://docs.brew.sh/).
