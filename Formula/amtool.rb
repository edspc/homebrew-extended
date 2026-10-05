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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "cc441fc73c6c33d42ce37ac85d953c8735ca826a8d2e9acfc720c86c0bac6547"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d214974eef4afc27b3fa9fc1f5d1650130400ea25beeb274095b3e05482ce404"
    sha256 cellar: :any,                 x86_64_linux:      "f511065dfa8c91323b7ca44e71343c0e12293d7ee4854c9a22899424b1e63797"
  end

  depends_on "go" => :build

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/prometheus/common/version.Version=#{version}
      -X github.com/prometheus/common/version.BuildUser=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:, tags: "netgo"), "./cmd/amtool"

    generate_completions_from_executable(bin/"amtool", shell_parameter_format: "--completion-script-",
                                                       shells:                 [:bash, :zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/amtool --version 2>&1")

    (testpath/"alertmanager.yml").write <<~YAML
      route:
        receiver: default
      receivers:
        - name: default
    YAML
    assert_match "SUCCESS", shell_output("#{bin}/amtool check-config #{testpath}/alertmanager.yml")
  end
end
