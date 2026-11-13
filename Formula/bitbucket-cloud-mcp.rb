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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a069c31ef900e168288cd7c506400d3c71ccf1b0dd2bc83f92c0824125d720a3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "13c61674a445d60af7be0e155f9ac9a6846542c37ddf7a7a540faf36dd48fccf"
    sha256 cellar: :any,                 x86_64_linux:      "ab27089f743d232f0bec876d3e3cb14e165d17cb2e521c00d9af6e42454acfa2"
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
