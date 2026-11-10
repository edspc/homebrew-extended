class Amtool < Formula
  desc "CLI for the Prometheus Alertmanager"
  homepage "https://github.com/prometheus/alertmanager"
  url "https://github.com/prometheus/alertmanager/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "4c4355655ee6d303991fba6e10ca2357978ca9ca0fb47ce925482d685aa34ff7"
  license "Apache-2.0"
  head "https://github.com/prometheus/alertmanager.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a40d047781cf7c62c69ce7d722c4e2a8a44fac225fd27366849fe3778ea8c93a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "aba99de6d5b511c81439e9430ab1096e2c09bedd130768bfbdbc097f3ac8d9da"
    sha256 cellar: :any,                 x86_64_linux:      "330d9b5d76a5a9a801f4338f471782d2238dbc8aab3ec35285b1e16bf4057faf"
  end

  depends_on "go" => :build

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Like upstream's release builds: a detached `HEAD` at the tag's commit,
    # which `git archive` stores in the header of the GitHub tarball. The build
    # date is `time`, which Homebrew pins to the source's date for reproducible bottles.
    if build.head?
      branch = Utils.git_branch
      revision = Utils.git_head
    else
      branch = "HEAD"
      revision = Utils::Git.get_tar_commit_id(cached_download)
    end
    ldflags = %W[
      -X github.com/prometheus/common/version.Version=#{version}
      -X github.com/prometheus/common/version.Revision=#{revision}
      -X github.com/prometheus/common/version.Branch=#{branch}
      -X github.com/prometheus/common/version.BuildUser=#{tap.user}
      -X github.com/prometheus/common/version.BuildDate=#{time.strftime("%Y%m%d-%H:%M:%S")}
    ]
    system "go", "build", *std_go_args(ldflags:, tags: "netgo"), "./cmd/amtool"

    generate_completions_from_executable(bin/"amtool", shell_parameter_format: "--completion-script-",
                                                       shells:                 [:bash, :zsh])
  end

  test do
    output = shell_output("#{bin}/amtool --version 2>&1")
    assert_match version.to_s, output
    assert_match(/revision: \h{40}\)/, output)

    (testpath/"alertmanager.yml").write <<~YAML
      route:
        receiver: default
      receivers:
        - name: default
    YAML
    assert_match "SUCCESS", shell_output("#{bin}/amtool check-config #{testpath}/alertmanager.yml")
  end
end
