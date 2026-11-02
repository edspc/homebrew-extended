# Git conventions

- **No Claude attribution anywhere in git history.** No `Co-Authored-By:` trailer, no `Claude-Session:` line, no `https://claude.ai/...` URL in commits; no "Generated with Claude Code" footer or Claude link in pull requests. Enforced by `.claude/settings.json`.
- **Commits are unsigned and authored as the repo owner.** Cloud sessions may reset `git config` on a fresh clone, so check the author and committer identity before committing. `GIT_AUTHOR_*` and `GIT_COMMITTER_*` environment variables override `git config`.
- **No binary files in git.** Bottles live in GitHub Packages only.
- Formula commits use Homebrew's message style, the same as `brew bump` and `brew pr-pull` produce, one formula per commit: `foo 1.2.3` (version bump), `foo 1.0 (new formula)`, `foo: delete`, `foo: <change>`; `foo: update 1.2.3 bottle.` comes from `pr-pull`. Everything else uses Conventional Commits (`ci:`, `chore:`, `docs:`).
