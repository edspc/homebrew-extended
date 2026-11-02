# Homebrew environment notes

These observations were verified when the guidance was written. Recheck tool
versions and runner availability when changing the setup.

- Homebrew 6 requires tap trust for non-official taps: installing by the full name (`brew install edspc/extended/<formula>`) trusts that formula, short names need `brew trust` first.
- macOS bottles are built on `macos-26` (`arm64_tahoe`), as in the `brew tap-new` template, and additionally on macOS 27 (`arm64_golden_gate`); older macOS versions build from source. GitHub offers macOS 27 only as the public preview image `xcode-27`; there is no `macos-27` label yet, so switch to it once it exists. actionlint reports `xcode-27` as an unknown label, which `brew style` ignores.
- Pull requests opened by `autobump.yml` with `GITHUB_TOKEN` do not trigger `tests.yml` (GitHub does not start workflows for events caused by `GITHUB_TOKEN`); close and reopen the pull request to run CI.
- Cloud sessions: `brew` refuses to run as root (use a separate user with the default prefix `/home/linuxbrew/.linuxbrew`), Homebrew's portable Ruby trusts only its own `libexec/cert.pem` (append the session's proxy CA bundle there), and `--online` audits report URLs outside the session's network policy (GitHub repositories not attached to the session, some project sites) as unreachable (HTTP 403). GitHub tag archives of such repositories cannot be downloaded either, but `git clone` works and `git archive --format=tar --prefix=<repo>-<version>/ <tag> | gzip -cn` reproduces the archive byte for byte: use it for the `sha256` and seed `brew --cache -s <formula>` with it to build locally.
- `Homebrew/actions/git-user-config` (publish and autobump) commits as the GitHub user who triggered the run, with the public email of their profile if one is set, otherwise their noreply address.
