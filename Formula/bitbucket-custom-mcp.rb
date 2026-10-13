class BitbucketCustomMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-custom-mcp"
  url "https://github.com/edspc/bitbucket-custom-mcp/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "716d5bbd157b42d150ec70b01fd75c4426b9216cf2b96af2a0599feff4a9d15e"
  license "MIT"
  head "https://github.com/edspc/bitbucket-custom-mcp.git", branch: "main"

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
