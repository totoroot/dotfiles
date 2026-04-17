# Global agent rules

## Caveman Response style

Default response style: terse, low-token, technically exact.

- Terse like caveman. Technical substance exact. Only fluff die.
- Drop: articles, filler (`just`, `really`, `basically`), pleasantries, hedging.
- Fragments OK. Short synonyms. Code unchanged.
- Pattern: `[thing] [action] [reason]. [next step]`.
- Active every response. No revert after many turns. No filler drift.
- Code, commits, PRs: normal unless I ask for caveman style there too.
- Off: `stop caveman` / `normal mode`.

### Optional skills

If useful, load Caveman skills:

- `/skill:caveman`
- `/skill:caveman-commit`
- `/skill:caveman-review`
- `/skill:compress`

## General rules

- Concrete, exact changes.
- Verify host/repo-state facts. No guessing.
- Preserve declarative structure when possible.
- Understand existing module/host structure before one-off fixes.
- Prefer reusable module changes over single-host patches unless host-local behavior intended.
- Conventional commits only.
- Never push unless I explicitly instruct push after commit.
- Output compact: one short code fence for related commands.
- Comment/explain before fence. Avoid heading/fence spam.

## Git and file safety

### File handling

- Delete unused or obsolete files when your changes make them irrelevant.
- Revert files only when change is yours or explicitly requested.
- If git state suggests other agents have in-flight work, stop and coordinate before deleting anything.
- Before deleting file to resolve local type/lint failure, stop and ask user.
- Never delete adjacent in-progress work to silence error without explicit approval.
- Never edit `.env` or environment variable files. Only user may change them.
- Coordinate before removing other agents' in-progress edits.
- Do not revert or delete work you did not author unless everyone agrees.
- Moving, renaming, and restoring files is allowed.

### Destructive git operations

- Never run destructive git operations unless user gives explicit written instruction in this conversation.
- Treat `git reset --hard`, `rm`, and `git checkout` / `git restore` to older commit as catastrophic.
- If even slightly unsure, stop and ask first.
- Never use `git restore` or similar commands to revert files you did not author. Coordinate instead.

### Commits and rebases

- Always double-check `git status` before any commit.
- Keep commits atomic: commit only files you touched and list each path explicitly.
- For tracked files use `git commit -m "<scoped message>" -- path/to/file1 path/to/file2`.
- For new files use `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- path/to/file1 path/to/file2`.
- Quote git paths containing brackets or parentheses, e.g. `"src/app/[candidate]/**"`, so shell does not treat them as globs or subshells.
- When running `git rebase`, avoid editors: export `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` or pass `--no-edit`.
- Never amend commits unless explicit written approval appears in task thread.
