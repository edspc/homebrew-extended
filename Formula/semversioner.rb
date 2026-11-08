class Semversioner < Formula
  include Language::Python::Virtualenv

  desc "Semantic versioning management tool"
  homepage "https://github.com/raulgomis/semversioner"
  url "https://files.pythonhosted.org/packages/22/6b/bbc7290e276aba022d1d383219d87a57854a7551c898fbae34736e013df3/semversioner-3.1.0.tar.gz"
  sha256 "d3b620609d38967ac9a0a099226623aef4d5c421c513c5e3c189adb426e21ced"
  license "MIT"
  head "https://github.com/raulgomis/semversioner.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "793bbd41009153671b7599c10069f903283a230291293771b9755e5aea8984bf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "329b47ed055e6d82660121af2456204fa172e7556d2bb9e64b36e541dce1e46a"
    sha256 cellar: :any,                 x86_64_linux:      "91a41759a5b96577899c5ca36bc8caf1058f82e9f5a249cf85c6586cb0fe82fb"
  end

  depends_on "python@3.14"

  resource "click" do
    url "https://files.pythonhosted.org/packages/45/37/edbf1b0707709013c0cf2e8317e03d97ed29bf4cac709fe328904ae92a38/click-8.5.1.tar.gz"
    sha256 "9bbfada76703fd1d784b83eea012e3e8c6a001a876543ef104fa56aaaeb072b4"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz"
    sha256 "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/38/9b/e422a865e1d5d57d0e509b4e0bf1c1a70a7f6382c29a5aa428df994c8bc8/markupsafe-3.0.4.tar.gz"
    sha256 "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
    sha256 "94edc256424af38762eb31306eed28beb9f0efc50a8837492c9d6fd6004aed79"
  end

  def install
    virtualenv_install_with_resources

    generate_completions_from_executable(bin/"semversioner", shell_parameter_format: :click)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/semversioner --version")

    system bin/"semversioner", "add-change", "-t", "minor", "-d", "Initial release"
    system bin/"semversioner", "release"
    assert_match "0.1.0", shell_output("#{bin}/semversioner current-version").strip
  end
end
