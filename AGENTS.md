# Agent guide

## Project and layout

Homebrew tap `edspc/extended`: install with
`brew install edspc/extended/<formula>`. Formulae live in `Formula/`; casks use
`Casks/` when added. User installation instructions are in [README.md](README.md).
Published bottles use `https://ghcr.io/v2/edspc/extended`.

- [tests.yml](.github/workflows/tests.yml): tap syntax, formula installation,
  tests and bottles on macOS and Linux.
- [publish.yml](.github/workflows/publish.yml): manual `brew pr-pull` publication,
  bottle upload, provenance and push to `main`.
- [autobump.yml](.github/workflows/autobump.yml): daily version-bump PRs.
- [dependabot.yml](.github/dependabot.yml): grouped pinned-action updates.

## Commands

```sh
brew style edspc/extended
brew audit --strict --online --tap=edspc/extended
brew readall --aliases --os=all --arch=all edspc/extended
brew livecheck --tap=edspc/extended
brew install --build-from-source edspc/extended/<formula>
brew test edspc/extended/<formula>
brew linkage --test edspc/extended/<formula>
brew update-python-resources edspc/extended/<formula>
brew install --cask edspc/extended/<token>
```

## Rules and task workflows

Read [Repository conventions](.agents/rules/repository.md),
[Security](.agents/rules/security.md), [Git conventions](.agents/rules/git.md)
and the [Change lifecycle](.agents/rules/lifecycle.md) before changes.
For package work, read [Formulae and casks](.agents/rules/packages.md); for CI,
read [Workflows](.agents/rules/workflows.md).
[Environment notes](.agents/rules/environment.md) cover tap trust, runners,
cloud certificates and automation identity.

Use [Add a formula or cask](.agents/skills/add-homebrew-package/SKILL.md) for a new
package. [Project skills](.agents/skills/README.md) indexes the workflows.

`CLAUDE.md` points here. `.claude/rules` and `.claude/skills` point to the canonical
`.agents` directories for Claude compatibility.
