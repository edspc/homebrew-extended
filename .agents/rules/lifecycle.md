# Change lifecycle

## Validation

The verification gate is `brew style`, `brew audit --strict --online`, installation
with `--build-from-source` and `brew test` for every changed formula. Check loading
with `brew readall`. CI (`tests.yml`) runs formula checks through `brew test-bot`.
For casks, use the applicable checks in the
[package skill](../skills/add-homebrew-package/SKILL.md). Report unavailable
checks accurately; do not claim CI or installation succeeded without running it.

## Landing changes

- **Bottles come only from `brew pr-pull`.** Never write `bottle do` checksums by hand and never land a formula change with the GitHub merge button: the publish workflow uploads the bottles, adds the bottle commit and pushes to `main`. A change that invalidates the published bottles (new version, `revision`, dependency) drops the `bottle do` block, so a formula that lands without bottles builds from source instead of pouring a stale bottle.

1. Change the formula on a branch and open a pull request.
2. Wait until `brew test-bot` is green on all runners.
3. Run the `brew pr-pull` workflow (Actions → brew pr-pull → Run workflow) with the pull request number. `workflow_dispatch` only sees workflows on `main`, so changes to `publish.yml` itself land first.

Pull requests without formula changes (workflows, documentation, agent configuration) are merged normally.

Cask-only changes are not bottled. Use the ordinary PR path after their applicable
checks; use the bottle publisher when a PR changes formulae.
