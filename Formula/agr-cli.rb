class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  version "0.6.3"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "444214c0ad4ddac1047fce0fe740c412ccab1702aed871c77e4102a98fa2c852"
    sha256 cellar: :any_skip_relocation, sequoia:      "8970dd4aba13cc32a649842a8e8f87d4b2f8c3861b55a38720b72d85ad1d9334"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "52a25f680e84bc4f25ba1762c569fa7c67d68fc15a8128715f1c034f6b4a5cac"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a1f840ecfc84d6431c8ec20f996af7bda6ed8e82c806ab47187c0f9814b967c3"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.3/agr-0.6.3-darwin-arm64.tar.gz"
      sha256 "66c1d90013dd0039584bf388592ed357dea3657a2a80a6c37c875a0d7c273c9e"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.3/agr-0.6.3-darwin-amd64.tar.gz"
      sha256 "2c01dce41f6863659057aa6468eeaad372f04a82d3230f2d0342a0e13dd2dd4f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.3/agr-0.6.3-linux-arm64.tar.gz"
      sha256 "93b850f1a8b2825dc2d65587c49ebcaac589b227e326c44147f5df0848ac6036"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.3/agr-0.6.3-linux-amd64.tar.gz"
      sha256 "eda763a330d56a77d36e47aab7fae0a63f77f6e63d6c035f79d80a9b5deffbd7"
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
