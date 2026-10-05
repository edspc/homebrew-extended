class Semversioner < Formula
  include Language::Python::Virtualenv

  desc "Semantic versioning management tool"
  homepage "https://github.com/raulgomis/semversioner"
  url "https://files.pythonhosted.org/packages/1a/72/3cfeb2091e2721f96ef7a2d53309388a576e176b6870209c282209acd7ac/semversioner-3.0.3.tar.gz"
  sha256 "759625e71c24fd60a3c0b8819c8c0e8cdd6602b6d4878cf33f9dd302bf763708"
  license "MIT"
  head "https://github.com/raulgomis/semversioner.git", branch: "master"

  depends_on "python@3.14"

  resource "click" do
    url "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz"
    sha256 "ba0d2089de75ea0310e2dde03160e6ca10009947fb95a182f9b54021bb272e34"
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
