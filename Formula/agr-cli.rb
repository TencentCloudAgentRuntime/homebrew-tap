class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/tencentcloudagentruntime/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "9eeb23cd8b16958c786b9fa293c7ddd7b7948bd5c71275dded48c22d9b57c5d8"
    sha256 cellar: :any_skip_relocation, sequoia:      "8265f406614f83c8c7dc914e75636e79aced42dbab780c1e531d79873fc2b013"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "f4cf22a5daef8c7c5c369c1926966029a6a34b7fdcc24f9958f78e03a4195dc0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "afd0363c566b69d15df8cdf528df107e235a02d10417ae68908f3cb7961b4289"
  end

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.7/agr-0.6.7-darwin-arm64.tar.gz"
      sha256 "0967cfa946b06a3238a9f93d6c820e6d966ab3f27a4e3faf68ce94cbccf49661"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.7/agr-0.6.7-darwin-amd64.tar.gz"
      sha256 "56a15348efd685c1ad972e73b085c723185bae0e058b8a47a0f40b49b17b5a48"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.7/agr-0.6.7-linux-arm64.tar.gz"
      sha256 "3c9b4a9edb7be5d7dfd17a4033954c6950414d3b84b7a899f9c49aaa7208a557"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.7/agr-0.6.7-linux-amd64.tar.gz"
      sha256 "4b23edf43228edfea0d105554c3922906ef6e177a2064637732a619acee0c683"
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
