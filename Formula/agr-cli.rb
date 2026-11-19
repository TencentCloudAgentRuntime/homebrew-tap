class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "299e2c55f3bf208d202b36f9f00f7a4e4b7a7607fa1f39aca66610ab49798f0c"
    sha256 cellar: :any_skip_relocation, sequoia:      "43df14d9633c8eccc288d7d5deb51e3f288df0d7f021d6618975c180cbd9af5f"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "54da578360526c654ad85604f3c8b3c1c9b8acd11c9b3748413a17fba0e90073"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e0ca64646231cda96f1f5b7c153fff48e4311afc8bb30f2939cffb42a10e2872"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.2/agr-0.7.2-darwin-arm64.tar.gz"
      sha256 "a49ec467a43165d6d4e9747cd55f3fdf87205f18b77a0277fe317e6b992041d0"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.2/agr-0.7.2-darwin-amd64.tar.gz"
      sha256 "835be9b3f1dbb3d1f891aa69ccf39d69bcc3005044b9894f2cc93dc8d9c1ede6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.2/agr-0.7.2-linux-arm64.tar.gz"
      sha256 "e503f83e20a2746b1919e5dac4bdcfd68f5ec6e96e0d5b4e6475a108fd22006f"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.2/agr-0.7.2-linux-amd64.tar.gz"
      sha256 "14e67f983fd72b99332152b43b3ec01a25812aa468e2ad94927a63cf41880440"
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
