class BitbucketCustomMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-custom-mcp"
  url "https://github.com/edspc/bitbucket-custom-mcp/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "a20e385ed2f759015507d996396056c140c2a6ba79eaa599bb6904a68654420e"
  license "MIT"
  head "https://github.com/edspc/bitbucket-custom-mcp.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8d78a7e2c83486937a8e3d8c3bf06fb74d5383b88712ac122b6fe5a73d1422eb"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2d69d0316755927c7b9f28cee1e2d87e841616fa20205b40de510d1e3fcee9e0"
    sha256 cellar: :any,                 x86_64_linux:      "1307461ba4ed0312c040f0655d2d4a0ae4ee64f196929a55b8957f04a4b0cee8"
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
