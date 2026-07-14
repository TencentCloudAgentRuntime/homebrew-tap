class AgrCli < Formula
  desc "CLI for Tencent Cloud Agent Runtime"
  homepage "https://github.com/TencentCloudAgentRuntime/ags-cli"
  version "0.6.2"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.2/agr-0.6.2-darwin-arm64.tar.gz"
      sha256 "07e3f225f71aa4fd7f675f503e2663a263dd3fdfdfa10e208518659b42484ad6"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.2/agr-0.6.2-darwin-amd64.tar.gz"
      sha256 "0d94c7ecfc2fc251e49c90273154e132f11a7e0b6096cd60218a5c2d33961fcb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.2/agr-0.6.2-linux-arm64.tar.gz"
      sha256 "293664bd4d8c9612b05e83d349fd047af0a0d24279bda576d1c2664c259fbae6"
    end

    on_intel do
      url "https://github.com/TencentCloudAgentRuntime/ags-cli/releases/download/v0.6.2/agr-0.6.2-linux-amd64.tar.gz"
      sha256 "19797a581c37a8a9e151086eda13d2461fb2ba1bad7b7e1acdbc15dc15309679"
    end
  end

  def install
    bin.install "agr"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agr version")
    assert_match '"Name":"instance.create"', shell_output("#{bin}/agr schema instance.create -o json")
  end
end
