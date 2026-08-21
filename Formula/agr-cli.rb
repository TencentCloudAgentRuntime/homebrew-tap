class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "bf311da84ade022970c7539cb9563c454da02d44a1812fccd03eced8ad304a0b"
    sha256 cellar: :any_skip_relocation, sequoia:      "60e2f3e35cc348719ce5101069b0f32644cb082e496f0cc458d2f88909ba1373"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "0abab8416fd31d41b43042d9fba566ae7390edfb4229ef39748e64d279131647"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "55de181193b31711da91d9596a6293a484c133012a333279512700d3042b787f"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.5/agr-0.6.5-darwin-arm64.tar.gz"
      sha256 "a2a0880b659f33da020b179653fac2aa4d422e647d80fc8872372f33606112eb"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.5/agr-0.6.5-darwin-amd64.tar.gz"
      sha256 "3aa45bcdf00c25ab970873be2b8109cce6f87fe5f4ab206a80d8f4a45e426cac"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.5/agr-0.6.5-linux-arm64.tar.gz"
      sha256 "9820a29049c17c76e45161a9097463db5fe9729e081176ffae8c7f30b09595f2"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.5/agr-0.6.5-linux-amd64.tar.gz"
      sha256 "5cc7716543aaaf9bf39f8864cd44abb359a16734d2773b0211c2dbf730c20e26"
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
