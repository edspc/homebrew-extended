class BitbucketCloudMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-cloud-mcp"
  url "https://github.com/edspc/bitbucket-cloud-mcp/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "ffaac8924969a9eed78a2d01f440e46146bc3cf9efd18e8e1f4300c4d23f9f69"
  license "MIT"
  head "https://github.com/edspc/bitbucket-cloud-mcp.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7928b7ae56a141821ab89d99a026ef034f2557236bb7c71951c3c69ba7735f7b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5236b714f6de356c3f277c2dd67aa7479a8b2d45bf17dba8e4104e5df1ca3990"
    sha256 cellar: :any,                 x86_64_linux:      "7c38fe27947e944d9720b7f6a93689be446efe8fcbcb681cfa7120ebdbb6739d"
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
