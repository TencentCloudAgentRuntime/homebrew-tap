class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  version "0.6.3"
  license "Apache-2.0"

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
