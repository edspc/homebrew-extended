class Semversioner < Formula
  include Language::Python::Virtualenv

  desc "Semantic versioning management tool"
  homepage "https://github.com/raulgomis/semversioner"
  url "https://github.com/raulgomis/semversioner/archive/refs/tags/1.7.0.tar.gz"
  sha256 "fe21250c7c1e3f76ad37bbad714b828873f20899eda56f05464e1d93107e1f35"
  license "MIT"
  head "https://github.com/raulgomis/semversioner.git", branch: "master"

  bottle do
    root_url "https://github.com/edspc/homebrew-extended/releases/download/semversioner-1.7.0"
    sha256 cellar: :any_skip_relocation, ventura:      "953d0ca670120d2c82656296767f7dbc41b8c15dca932f89da0895bd4bcfc948"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "48e5f0a626c7d4538853e0663efb31f25372afd29ffa430756dc5077fccf2503"
  end

  depends_on "python@3.12"

  resource "click" do
    url "https://files.pythonhosted.org/packages/96/d3/f04c7bfcf5c1862a2a5b845c6b2b360488cf47af55dfa79c98f6a6bf98b5/click-8.1.7.tar.gz"
    sha256 "ca9853ad459e787e2192211578cc907e7594e294c7ccc834310722b41b9ca6de"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/7a/ff/75c28576a1d900e87eb6335b063fab47a8ef3c8b4d88524c4bf78f670cce/Jinja2-3.1.2.tar.gz"
    sha256 "31351a702a408a9e7595a8fc6150fc3f43bb6bf7e319770cbc0db9df9437e852"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/6d/7c/59a3248f411813f8ccba92a55feaac4bf360d29e2ff05ee7d8e1ef2d7dbf/MarkupSafe-2.1.3.tar.gz"
    sha256 "af598ed32d6ae86f1b747b82783958b1a4ab8f617b06fe68795c7f026abbdcad"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/fb/2b/9b9c33ffed44ee921d0967086d653047286054117d584f1b1a7c22ceaf7b/packaging-23.2.tar.gz"
    sha256 "048fb0e9405036518eaaf48a55953c750c11e1a1b68e0dd1a9d62ed0c092cfc5"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"semversioner", "add-change", "-t", "minor", "-d", "Initial release"
    system bin/"semversioner", "release"
    assert_match "0.1.0", shell_output("#{bin}/semversioner current-version").strip
  end
end
