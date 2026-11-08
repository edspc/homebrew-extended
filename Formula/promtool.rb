class Promtool < Formula
  desc "Tooling for the Prometheus monitoring system"
  homepage "https://prometheus.io/docs/prometheus/latest/command-line/promtool/"
  url "https://github.com/prometheus/prometheus/archive/refs/tags/v3.16.0.tar.gz"
  sha256 "2709a3bd43f9d15e0cecfc33ab473d011e2a69ab29265b91398cc1b8561403c0"
  license "Apache-2.0"
  head "https://github.com/prometheus/prometheus.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b9c0da5cb4b57c427e123edf77da1e8009fe8758541f6adbdde7b16c08655b86"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3deba33129ad28b8267f0e4b8dde2f24517ea7a7484c5167e61e0120c16679a1"
    sha256 cellar: :any,                 x86_64_linux:      "0a4aff389ba649f045efe00380cf64abbe4ef46014e4294509d94338e12a9975"
  end

  depends_on "go" => :build

  conflicts_with "prometheus", because: "both install `promtool`"

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
    system "go", "build", *std_go_args(ldflags:, tags: "netgo"), "./cmd/promtool"

    generate_completions_from_executable(bin/"promtool", shell_parameter_format: "--completion-script-",
                                                         shells:                 [:bash, :zsh])
  end

  test do
    output = shell_output("#{bin}/promtool --version 2>&1")
    assert_match version.to_s, output
    assert_match(/revision: \h{40}\)/, output)

    (testpath/"rules.yml").write <<~YAML
      groups:
        - name: http
          rules:
            - record: job:http_inprogress_requests:sum
              expr: sum(http_inprogress_requests) by (job)
    YAML
    assert_match "SUCCESS", shell_output("#{bin}/promtool check rules #{testpath}/rules.yml")
  end
end
