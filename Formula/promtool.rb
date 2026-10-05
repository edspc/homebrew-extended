class Promtool < Formula
  desc "Tooling for the Prometheus monitoring system"
  homepage "https://prometheus.io/docs/prometheus/latest/command-line/promtool/"
  url "https://github.com/prometheus/prometheus/archive/refs/tags/v3.15.0.tar.gz"
  sha256 "d6383dea2f9b26c1673a52859c453653f2c6c046f7fb6d01db59603a65a732eb"
  license "Apache-2.0"
  head "https://github.com/prometheus/prometheus.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build

  conflicts_with "prometheus", because: "both install `promtool`"

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/prometheus/common/version.Version=#{version}
      -X github.com/prometheus/common/version.BuildUser=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:, tags: "netgo"), "./cmd/promtool"

    generate_completions_from_executable(bin/"promtool", shell_parameter_format: "--completion-script-",
                                                         shells:                 [:bash, :zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/promtool --version 2>&1")

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
