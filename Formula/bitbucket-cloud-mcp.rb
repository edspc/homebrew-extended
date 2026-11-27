class BitbucketCloudMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-cloud-mcp"
  url "https://github.com/edspc/bitbucket-cloud-mcp/archive/refs/tags/v0.9.1.tar.gz"
  sha256 "1be5e6c994b71f1d8f7a69367566d41e2ef94740cb28c90a4e91235e978b8ae1"
  license "MIT"
  head "https://github.com/edspc/bitbucket-cloud-mcp.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    manifest_sha256 "ecd871575369baa527a743911ca11eb3dc6cb0bce1ba1bab70cdcfbcecdfbc7a"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7e7c69d0fface11a9aaf5142158afee57452aaf9fa0344af136690ee41ee3f17"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "08859db689c904cea7e5d6e77f3df259d2e1533e53c8655f2d0e3bc11ac7f1a4"
    sha256 cellar: :any,                 x86_64_linux:      "af17d474b2e52da9918b78c9a36c67881d98af822ace8a21501ccbbf1e47694e"
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

    assert_equal "bitbucket-cloud-mcp #{version}", shell_output("#{bin}/bitbucket-cloud-mcp --version").strip

    env = {
      "BITBUCKET_WORKSPACE"        => "offline-test",
      "BITBUCKET_EMAIL"            => "homebrew@example.invalid",
      "BITBUCKET_API_TOKEN"        => "not-a-real-token",
      "BITBUCKET_ALLOWED_REPOS"    => "[]",
      "BITBUCKET_ALLOWED_PROJECTS" => "[]",
      "BITBUCKET_ALLOWED_TOOLS"    => "[]",
      "BITBUCKET_ALLOWED_REFS"     => "[]",
    }
    IO.popen(env, [bin/"bitbucket-cloud-mcp"], "r+") do |io|
      io.puts JSON.generate(jsonrpc: "2.0", id: 1, method: "initialize", params: {
        protocolVersion: "2025-11-25",
        capabilities:    {},
        clientInfo:      { name: "homebrew-test", version: "1" },
      })
      io.flush
      response = Timeout.timeout(15) { JSON.parse(io.readline) }
      assert_equal 1, response.fetch("id")
      server_info = response.fetch("result").fetch("serverInfo")
      assert_equal "bitbucket-cloud-mcp", server_info.fetch("name")
      assert_equal version.to_s, server_info.fetch("version")

      io.puts JSON.generate(jsonrpc: "2.0", method: "notifications/initialized")
      io.puts JSON.generate(jsonrpc: "2.0", id: 2, method: "tools/list")
      io.flush
      tools = Timeout.timeout(15) { JSON.parse(io.readline) }
      assert_equal 2, tools.fetch("id")
      assert_includes tools.fetch("result").fetch("tools").map { |tool| tool.fetch("name") }, "search_code"
      io.close_write
    end
  end
end
