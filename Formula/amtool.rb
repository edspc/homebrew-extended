class Amtool < Formula
  desc "CLI for the Prometheus Alertmanager"
  homepage "https://github.com/prometheus/alertmanager"
  url "https://github.com/prometheus/alertmanager/archive/refs/tags/v0.34.2.tar.gz"
  sha256 "33ec4dffd171e4d4434e81f005ef2fba9e624697505333abd22a1fddb74409e6"
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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "06610bd8967ba0d00b0dacf72554247d1227ca464cfabf21fe8257a02a9819d5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8bef21c521f6fa027df3cb13f748b87ffddbadd742d3d5cb7e5b3e7d0193deac"
    sha256 cellar: :any,                 x86_64_linux:      "60f92c9ff680f5e98c9f6400ab4799a3d4492de9e65c06573748a467bc3a3bc9"
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
