---
name: add-homebrew-package
description: Add a Homebrew formula or cask to edspc/extended, including upstream downloads, checksums, installation checks, CI and publication.
---

# Add a formula or cask

Read [Packages](../../rules/packages.md), [Security](../../rules/security.md),
[Git conventions](../../rules/git.md) and [Change lifecycle](../../rules/lifecycle.md).
For CI changes read [Workflows](../../rules/workflows.md); for local constraints
read [Environment notes](../../rules/environment.md).

## Identify the distribution

1. Confirm the upstream project, requested version, license, supported OS/CPU
   combinations and official downloads. Check existing `Formula/`, `Casks/` and
   rename/migration mappings before introducing another package name.
2. Choose a formula or cask from the distribution and desired installation
   behavior. Consult the current [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
   or [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook). A prebuilt binary alone
   does not determine which package type to use.
3. Download each supported platform artifact from its official, versioned HTTPS
   URL into a temporary directory outside version control. Compute its SHA-256
   and compare available upstream checksums/signatures. Source archives and
   executables have different digests. A repository rename can change archive
   bytes; verify the final URL rather than copying an old checksum.

## Add a formula

1. Create `Formula/<name>.rb` with the matching Ruby class, description, homepage,
   license, URL and verified SHA-256. Let Homebrew infer the version from the URL
   when possible; a redundant explicit version fails audit.
2. For source builds, declare actual dependencies and keep network fetching out
   of `install`. Follow the existing language recipes: regenerate Python
   resources with `brew update-python-resources`, or use `std_go_args` for Go.
3. For upstream executables, follow the `bitbucket-cloud-mcp` formula: choose
   OS/CPU artifacts, verify each digest, install the intended command name with
   executable permissions, and omit compiler-only dependencies. A binary-only
   installer must not keep an incompatible source-only `head` stanza.
4. Add an offline `test do` for meaningful installed behavior. For an MCP server,
   check its version, initialization and tools using fake credentials, without
   live API calls. Do not add or edit `bottle do` checksums.
5. Run the validation below with the real package name. Keep the fully qualified
   tap name so the check targets this recipe.

   ```sh
   brew style edspc/extended
   brew readall --aliases --os=all --arch=all edspc/extended
   brew audit --new edspc/extended/<name>
   brew install --build-from-source edspc/extended/<name>
   brew test edspc/extended/<name>
   brew linkage --test edspc/extended/<name>
   ```

## Add a cask

1. Create `Casks/<token>.rb` and use that token in the `cask` header. Provide the
   version, verified checksum, official URL, name, description and homepage.
   Select artifact stanzas such as `app`, `pkg` or `binary` from the actual payload.
2. Describe architecture/OS differences and platform requirements explicitly.
   Derive uninstall, zap, livecheck and update behavior from upstream installation
   behavior; do not invent cleanup paths or arbitrary installer scripts.
3. Run `brew style Casks/<token>.rb`, `brew readall` and
   `brew audit --new --cask edspc/extended/<token>`. Install with
   `brew install --cask edspc/extended/<token>` in a suitable isolated test
   environment and verify the installed artifact. `brew test` is for formulae.
4. Inspect CI coverage: add the applicable cask audit/install checks when the
   existing formula test-bot does not exercise them. Test supported platforms
   and report exactly which installation checks ran.

## Review and land

1. Update README install/setup instructions. For a rename, update the relevant
   Homebrew rename/migration mapping and document the new command path.
2. Open a PR within the user's authorized scope and wait for applicable CI.
   Fix failures without skipping audits or weakening meaningful tests.
3. Formula changes land through `brew pr-pull` with the PR number and expected
   head SHA after all required runners pass. Wait for bottle upload, provenance
   and push, then verify the recipe on `main`.
4. Cask-only PRs use the ordinary merge path after their checks; they do not use
   the formula bottle publisher. Respect the user's requested merge method.
5. Report the package/version, install or migration command, checks and any
   unavailable validation. This workflow does not authorize unrelated publication.
