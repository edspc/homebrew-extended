class BitbucketCloudMcp < Formula
  desc "MCP server for Bitbucket Cloud"
  homepage "https://github.com/edspc/bitbucket-cloud-mcp"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/edspc/bitbucket-cloud-mcp/releases/download/v0.6.0/bitbucket-cloud-mcp-darwin-arm64"
      sha256 "c1b3790cb21971c647c5cc26839cba0399cf48c832cdf04e135b963062934e4b"
    end

    on_intel do
      url "https://github.com/edspc/bitbucket-cloud-mcp/releases/download/v0.6.0/bitbucket-cloud-mcp-darwin-amd64"
      sha256 "2425339ee8935c908bb329890d355a84fa6f4fbedfda858ead41d2b32b6486dc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/edspc/bitbucket-cloud-mcp/releases/download/v0.6.0/bitbucket-cloud-mcp-linux-arm64"
      sha256 "b0cdcb3e4b4cac0e7dcfe9c62d82dbb9ebae9c43e37f608394adf7330e13bfb6"
    end

    on_intel do
      url "https://github.com/edspc/bitbucket-cloud-mcp/releases/download/v0.6.0/bitbucket-cloud-mcp-linux-amd64"
      sha256 "bf9917fc2bb8d81d4726e4b545c013444e04f29f72842b3e4a63e10c504020f0"
    end
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "bitbucket-cloud-mcp-#{os}-#{arch}" => "bitbucket-cloud-mcp"
    chmod 0755, bin/"bitbucket-cloud-mcp"
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
