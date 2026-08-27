class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "b0a40aa830594b50506268c05c57109eeaf634afa63d218d72af0570fafb866a"
    sha256 cellar: :any_skip_relocation, sequoia:      "9ae7ebf5be4edcded1420f444d5c898c3d5c2291243076a4c31357188b432bd0"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "2eb44ec21c923f3beced024dbad97e84595887a238b38fe9e0aff497def70fda"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "798ad0b12717f9285c505cb89ed3f6eb127ff0b661676cebb3c6e74b6ca5ce85"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.6/agr-0.6.6-darwin-arm64.tar.gz"
      sha256 "83aefed671ef0eb408bc7827c06eeb60b7180c7000b3dfff02578737af5b7f34"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.6/agr-0.6.6-darwin-amd64.tar.gz"
      sha256 "f753494c4940f9ac11abc006a269e1e24979aae7ac2d2a88ec5a7d4d46cfd20c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.6/agr-0.6.6-linux-arm64.tar.gz"
      sha256 "33fec9e375a71060d3afa868f2f2ff299c5912b4f4c2147b4840c0f1dc40f47d"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.6/agr-0.6.6-linux-amd64.tar.gz"
      sha256 "2279925b3b1c204d31c847fd38258a2640892b90b638d7215033de318f232719"
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
