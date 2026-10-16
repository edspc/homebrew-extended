class BitbucketCustomMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-custom-mcp"
  url "https://github.com/edspc/bitbucket-custom-mcp/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "d83e482c9ffd1a4fcb19641c0475a8f1a3ab5d023ff636b782ba330e9dedb671"
  license "MIT"
  head "https://github.com/edspc/bitbucket-custom-mcp.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "232a933c3630902243af92276389badee528bda3d9a39f5e17e023b6f7bff7b8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "023ec14644052eabac8b74589348a658ca3e44188f4442ce9609f7b737fbdf65"
    sha256 cellar: :any,                 x86_64_linux:      "9717eeb349e5ed1c0c4942b13bbc445ced55b668f9197027f740f704ca1bcc46"
  end

  depends_on "go" => :build

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "-buildvcs=false", "./cmd/server"
  end

  test do
    require "json"
    require "timeout"

    assert_equal "bitbucket-custom-mcp #{version}", shell_output("#{bin}/bitbucket-custom-mcp --version").strip

    env = {
      "BITBUCKET_WORKSPACE"        => "offline-test",
      "BITBUCKET_EMAIL"            => "homebrew@example.invalid",
      "BITBUCKET_API_TOKEN"        => "not-a-real-token",
      "BITBUCKET_ALLOWED_REPOS"    => "[]",
      "BITBUCKET_ALLOWED_PROJECTS" => "[]",
      "BITBUCKET_ALLOWED_TOOLS"    => "[]",
      "BITBUCKET_ALLOWED_REFS"     => "[]",
    }
    IO.popen(env, [bin/"bitbucket-custom-mcp"], "r+") do |io|
      io.puts JSON.generate(jsonrpc: "2.0", id: 1, method: "initialize", params: {
        protocolVersion: "2025-11-25",
        capabilities:    {},
        clientInfo:      { name: "homebrew-test", version: "1" },
      })
      io.flush
      response = Timeout.timeout(15) { JSON.parse(io.readline) }
      assert_equal 1, response.fetch("id")
      server_info = response.fetch("result").fetch("serverInfo")
      assert_equal "bitbucket-custom-mcp", server_info.fetch("name")
      assert_equal version.to_s, server_info.fetch("version")
      io.close_write
    end
  end
end
