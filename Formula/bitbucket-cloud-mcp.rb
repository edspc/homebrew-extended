class BitbucketCloudMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-cloud-mcp"
  url "https://github.com/edspc/bitbucket-cloud-mcp/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "c242bc06ee94c9acb5a7b5942f18f60a422271401edd751ac2b88798eee5d621"
  license "MIT"
  head "https://github.com/edspc/bitbucket-cloud-mcp.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "101b5635f2d8b45381ca31b9e5de94023e8a4cee84e3e8776d97dda963242609"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c7c5abc4f59fc87e5456d1c83c0c4e94ad03967aff8092c2605a69a833bd2389"
    sha256 cellar: :any,                 x86_64_linux:      "f370fc196767ad51707605dbfcb8874a25946a6c1983a7d2310f67837e36c773"
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
