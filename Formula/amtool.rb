class Amtool < Formula
  desc "CLI for the Prometheus Alertmanager"
  homepage "https://github.com/prometheus/alertmanager"
  url "https://github.com/prometheus/alertmanager/archive/refs/tags/v0.35.1.tar.gz"
  sha256 "6522f9e6966114e8018ac0c2f2f7d9ccdfc955ed1d263af9e38016409419309e"
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
    manifest_sha256 "7d068dea1198e46086295bc551005b90b9ad7f9cd3c9f510f0e742fa7883c840"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b5c45607d077f246f613b310b079c9569e14619fcb992d63b1d47f70ce593f0a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "20f260b3eeb26e5bab33c11936834a7227c5d8ae2118ff85b0cec40c144a9f56"
    sha256 cellar: :any,                 x86_64_linux:      "4a0696906362f7c2a7266f4a7e95c8815a32f32ca7c48e5c9007c3272f424c5d"
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
