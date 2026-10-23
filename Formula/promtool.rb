class Promtool < Formula
  desc "Tooling for the Prometheus monitoring system"
  homepage "https://prometheus.io/docs/prometheus/latest/command-line/promtool/"
  url "https://github.com/prometheus/prometheus/archive/refs/tags/v3.15.1.tar.gz"
  sha256 "dc204963713b5fce7aca92292bc3bf69482b088f9d7a6761e60525750c1ddfd2"
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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3bd65ee76f4768bbcf6d0417aa03716dccf8d0ea54e9551ffca9468e1be3f198"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f83acbccc858cc0338973435682f7f6755db5fda567ed475f5a2fdfe0519a8f2"
    sha256 cellar: :any,                 x86_64_linux:      "e09c1ef461f39fb755311ffe45197b5f0ba64b2850fc354320e94de758425431"
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
