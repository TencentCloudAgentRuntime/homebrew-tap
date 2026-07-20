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
opens a Formula update pull request, and the `brew test-bot` checks build and
test Homebrew bottles for the supported macOS and Linux platforms.

The GitHub App used by the update workflow must be installed on this repository
with **Contents: read and write** and **Pull requests: read and write**. Configure
its credentials as below, and retain **Actions: read and write** for the release
workflow that dispatches the update:

- Repository variable `HOMEBREW_TAP_APP_ID`
- Repository secret `HOMEBREW_TAP_APP_PRIVATE_KEY`

After reviewing the Formula update and confirming all checks passed, run the
`brew pr-pull` workflow with the pull request number and reviewed head SHA. It
publishes the bottles to GitHub Packages, writes the generated `bottle do`
block, and pushes the resulting commits to `main`.

## Documentation

Run `brew help`, read `man brew`, or visit the
[Homebrew documentation](https://docs.brew.sh/).
