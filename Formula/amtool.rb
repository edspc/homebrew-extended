class Amtool < Formula
  desc "CLI for the Prometheus Alertmanager"
  homepage "https://github.com/prometheus/alertmanager"
  url "https://github.com/prometheus/alertmanager/archive/refs/tags/v0.34.1.tar.gz"
  sha256 "2f6bce4f4b2b28aec4e58fad1341f47cde9c30adb556399472a8831942057941"
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
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1e381627538e6a81e4d98548f12cc2da6e05af1f83007e4c932bd5d4aeaf9183"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "21a854628101cc7661acc1b13423a9a18d648918aa5ccd3767a6a718419cb7ef"
    sha256 cellar: :any,                 x86_64_linux:      "9e9f17af56c4e8b2a53ae7ca78ff07631ac21bf1ec15d2eccb973ef66d0b33eb"
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
