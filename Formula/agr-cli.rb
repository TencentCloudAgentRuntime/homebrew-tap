class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "edf64b1c3244a88598b1f5c49616a630103ae84e5f9d363e7f1c35c5a344ae1e"
    sha256 cellar: :any_skip_relocation, sequoia:      "37bfd20814579792099c7361317080d1f6072cc3eab71d5644a578a444426eb2"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "0fe3b9e6642879ddaf520371985a3295da9add5ab360e0b8c2cadfd4ceaee57f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3a4baec11461b917826cc6880497daef2f5caff0b87e778ad8da6ddff68a4326"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.1/agr-0.7.1-darwin-arm64.tar.gz"
      sha256 "c980b701f3182eec45c64fceea527ce732726388e672edfd09fe64aa244f527a"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.1/agr-0.7.1-darwin-amd64.tar.gz"
      sha256 "6ff345fdd68dd2963f6ce29c528c5b58cfcc66f20691594d31501d97df22db9b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.1/agr-0.7.1-linux-arm64.tar.gz"
      sha256 "99c8955564c913ab42796771e35c79d8dc8414e00eb615feda168e478cc8ad51"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.7.1/agr-0.7.1-linux-amd64.tar.gz"
      sha256 "a07b2782669df78eca66527c18d677b62cf7b5da18bda641aa4cc918c5a85776"
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
