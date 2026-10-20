class BitbucketCustomMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-custom-mcp"
  url "https://github.com/edspc/bitbucket-custom-mcp/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "944185d57cda1a4eaf5728e719fb7b440cfcee1c4fb0b58757f79c8170ecb40f"
  license "MIT"
  head "https://github.com/edspc/bitbucket-custom-mcp.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ba2d82145b4e1029f5090695019a6837fd59bc2f08ee6f78eb09453f1fafaaae"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2b42c9a227f9e75f78a84b7bd54af5a9e8411b23bf87857ad73e44a895ad373b"
    sha256 cellar: :any,                 x86_64_linux:      "3ca57fa153ab97cc7451d6634cc0cb7dd730074e1c4ad188bbd36c056f26a514"
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
