class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "d3e1a7dd4786e4a2b97651ed8786656f4bbd71c53bf797b3c004150db46ce667"
    sha256 cellar: :any_skip_relocation, sequoia:      "be52ed35d6f410ee0723bce009deec99e9d47949d8bfc7f87fa7c3c89c8a1fbe"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "8296e0da326cbe0a599c4494a0adafab9f4fa0c53f8f745eaee6b3302c2a4014"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a20c8842373e729deb29db842d64e6745d1fd115f19abc4d13c737c4c33ad815"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.0/agr-0.7.0-darwin-arm64.tar.gz"
      sha256 "df6f1634f15c6df50a7bf5922f46cf1c0a26b62ffe5033c8137e8b9958827024"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.0/agr-0.7.0-darwin-amd64.tar.gz"
      sha256 "b002ead9b51541e762662166c23f512b28a7cf33f5a51571d822815a39068dd6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.0/agr-0.7.0-linux-arm64.tar.gz"
      sha256 "627e3aaf67d143032bb5fcd09921dbba71ba1f0924c159b81b39e77c915418d0"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.0/agr-0.7.0-linux-amd64.tar.gz"
      sha256 "928ab569cfce797e58336b004068ba46be82d93a06a6a4c6b3950b0976c8314d"
    end
  end

  def install
    bin.install "agr"
  end

  def caveats
    <<~EOS
      AGR CLI is available as `agr`.

      Get started:
        agr --help

      Verify the installed version:
        agr version
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agr version")
    assert_match '"Name":"instance.create"', shell_output("#{bin}/agr schema instance.create -o json")
  end
end
