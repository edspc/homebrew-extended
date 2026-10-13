class BitbucketCustomMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-custom-mcp"
  url "https://github.com/edspc/bitbucket-custom-mcp/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "716d5bbd157b42d150ec70b01fd75c4426b9216cf2b96af2a0599feff4a9d15e"
  license "MIT"
  head "https://github.com/edspc/bitbucket-custom-mcp.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0d2842e7b6c4840301fbd3249d085b1d846bd36c679aa6c1b07d363043396f9f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f384dedaa622874cd66457569a15a674a79f0dc314398de089f67c4792bea1c7"
    sha256 cellar: :any,                 x86_64_linux:      "244f4cede84c25fbbde080361b8e463b1fdcc86d5f12234bb2284889c32a43d0"
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
