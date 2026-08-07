class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "60cd9e08f68865ebd02fc9ceb19e34b40aee317166e6747635c54babf606208c"
    sha256 cellar: :any_skip_relocation, sequoia:      "2586d78151947d8b06d31f03012449a9b06de9677ef86623653d664e4ab93bf9"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "34d424845d47991abbbac90f85cceef4f92d7e75530bcadc80adb975be70732d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "78b85193b64373fb0e81a0b7a62d1bc67d0a6a89bc4cadbe66a26baa028ba4b0"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.4/agr-0.6.4-darwin-arm64.tar.gz"
      sha256 "8760f213160a365ef0471d7de28fa30eedf5c27af38d2fcc09b28fe79722e491"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.4/agr-0.6.4-darwin-amd64.tar.gz"
      sha256 "e54a6a380e1de145023a117efa33f35bc1646e918ad20c650567250f4d341fa9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.4/agr-0.6.4-linux-arm64.tar.gz"
      sha256 "961347168672bf1721e2f8157be1d41f2f613b7fca636f007dab9a2d79ede035"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.4/agr-0.6.4-linux-amd64.tar.gz"
      sha256 "6dcf4843d7c71fe65410a6904f11ca8dff1dfd101b736eed0b210c7e4b02fe96"
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
