class ComposerAT22 < Formula
  desc "Dependency Manager for PHP"
  homepage "https://getcomposer.org/"
  url "https://getcomposer.org/download/2.2.23/composer.phar"
  sha256 "060ff6b6b8bfb60a943c94954cc4e8bf3e780ff33ecd7c7d9eb2f43241f39740"
  license "MIT"
  revision 1

  livecheck do
    url "https://getcomposer.org/download/"
    regex(%r{href=.*?/v?(#{Regexp.escape(version.major_minor)}(?:\.\d+)+)/composer\.phar}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "abec8f31dc83cc1b49a3f264f54da9c59b34ba0549e3117549cf12d30fe7ff03"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ae5878e9e6901188bd23de333db6ea910b0a701073be21e6584f1dc6c94ebef4"
  end

  keg_only :versioned_formula

  depends_on "php"

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "composer.phar" => "composer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/composer --version")
    (testpath/"composer.json").write <<~EOS
      {
        "name": "homebrew/test",
        "authors": [
          {
            "name": "Homebrew"
          }
        ],
        "require": {
          "php": ">=5.3.4"
          },
        "autoload": {
          "psr-0": {
            "HelloWorld": "src/"
          }
        }
      }
    EOS

    (testpath/"src/HelloWorld/Greetings.php").write <<~EOS
      <?php

      namespace HelloWorld;

      class Greetings {
        public static function sayHelloWorld() {
          return 'HelloHomebrew';
        }
      }
    EOS

    (testpath/"tests/test.php").write <<~EOS
      <?php

      // Autoload files using the Composer autoloader.
      require_once __DIR__ . '/../vendor/autoload.php';

      use HelloWorld\\Greetings;

      echo Greetings::sayHelloWorld();
    EOS

    system "#{bin}/composer", "install"
    assert_match(/^HelloHomebrew$/, shell_output("php tests/test.php"))
  end
end
