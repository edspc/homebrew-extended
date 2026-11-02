---
paths:
  - ".github/**"
---

# GitHub Actions

- **Workflows follow the `brew tap-new` templates** (`.github/workflows/tap-new-*.yml` in Homebrew/brew): `permissions: {}` at the top and the minimum per job, actions pinned to a commit SHA with the version in a comment (Dependabot updates them), no `pull_request_target`. When updating, diff against the current templates instead of editing ad hoc.

Keep the existing formula validation and `brew pr-pull` publication path intact.
For casks, check applicable style, audit and installation coverage on supported
platforms; a formula's `test do` is not a cask test.

## Workflow layout

- `.github/workflows/tests.yml` — `brew test-bot` on pushes to `main` and on pull requests: tap syntax (style, audit, readall), then build, test and bottle the changed formulae on `macos-26`, `xcode-27` (macOS 27) and on Linux (`ubuntu-latest` in the `ghcr.io/homebrew/brew` container); bottles are uploaded as workflow artifacts.
- `.github/workflows/publish.yml` — manual (`workflow_dispatch`, pull request number and optionally its expected head SHA): `brew pr-pull` downloads the pull request's bottles, uploads them to GitHub Packages, adds the bottle commit, attests build provenance and pushes to `main`. `pr-pull` appends `Closes #N.` to the last commit of the pull request, which closes it once pushed; delete its branch afterwards.
- `.github/workflows/autobump.yml` — daily `brew bump` opens version bump pull requests from branches in this repository.
- `.github/dependabot.yml` — weekly grouped updates of the pinned actions.
