class ComposerAT22 < Formula
  desc "Dependency Manager for PHP"
  homepage "https://getcomposer.org/"
  url "https://getcomposer.org/download/2.2.24/composer.phar"
  sha256 "b0c383b1f430a80a74c006f20199d1e0226848a0a90afa5c0a7d01fb90ee9075"
  license "MIT"

  livecheck do
    url "https://getcomposer.org/download/"
    regex(%r{href=.*?/v?(#{Regexp.escape(version.major_minor)}(?:\.\d+)+)/composer\.phar}i)
  end

  bottle do
    root_url "https://ghcr.io/v2/edspc/extended"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "080e60ef1681590df88b66637a4b7a30bf8888000477be368d3821756fc0442a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f18eb55391bb36570c822ef7e09de2a0e7d6f12d3c671aa1ce38bd0bdca9784b"
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
