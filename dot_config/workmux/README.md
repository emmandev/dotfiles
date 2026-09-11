# workmux cheatsheet

Git worktrees + tmux windows + parallel agents. Each task gets an isolated
worktree and a `wm-<task>` **window in the current session** (never a new
session → no sesh pollution). **Trial** — chezmoi-managed while evaluating;
not in the Brewfile yet.

## Our setup (decisions)
- **workmux only** (dropped worktrunk). Live agent dashboard was the hard
  requirement; worktrunk has no live view.
- **Global config only** (`~/.config/workmux/config.yaml`) — no per-project
  `.workmux.yaml` anywhere.
- **Layout**: single pane — `claude --model claude-opus-4-8` (Opus 4.8 pinned;
  the `opus` alias now tracks Opus 5), focused. No shell split.
- **Bootstrap**: symlink `node_modules` + `.husky/_`, copy `.env`/`.env.local`
  (no-op where absent → safe globally; monorepos are yarn/Nx with one hoisted
  root). `.husky/_` is husky's untracked runtime dir — without it, hooks in a
  worktree fail with "husky not installed" (existing broken worktree: run
  `yarn husky install` in it, or recreate it).
- **Finish**: PR flow → `workmux remove` (manual). Local-merge repos → dashboard `m`.
- **No tmux bindings** — run commands from a shell; drive the rest from the dashboard.

## Install / setup
```bash
brew install raine/workmux/workmux
workmux setup            # interactive — installs Claude Code status hooks
                         # (~/.claude/settings.json). REQUIRED or dashboard is empty.
```

## Commands
```bash
workmux add <task>       # worktree + wm-<task> window + claude, auto-switches
workmux dashboard        # TUI of all agents (track / switch / review / merge / steer)
workmux sidebar          # toggle the ambient agent-status list
workmux list             # list worktrees
workmux remove <task>    # manual cleanup: worktree + window + branch (no merge)
workmux merge [task]     # LOCAL merge into base + cleanup (see caveat below)
```

## Recipes

### Resume a PR after its worktree is gone
```bash
workmux add --pr <number>      # re-fetch the PR, recreate worktree + window;
                               # reuses the local branch if it still exists
```
`remove` deletes the *local* branch, but the remote branch + PR persist, so
`--pr` re-adopts them (even days later). By branch name instead:
`workmux add origin/<branch>` (fetches remote) or `workmux add <branch>` (reuses local).

### Stack a new PR on an open one
```bash
workmux add feature-b --base feature-a   # branch off feature-a, record it as the base
workmux add feature-b                    # ...or just this if already IN the feature-a
                                         #    worktree (base defaults to current branch)

git push -u origin feature-b
gh pr create --base feature-a --head feature-b   # PR #2 targets the parent, NOT main
```
Keep the stack in sync when the parent moves (e.g. PR #1 gets review changes):
```bash
workmux rebase feature-b                 # rebases onto the saved base (feature-a)
git push --force-with-lease origin feature-b
```
- `rebase` remembers the base from `add` — no need to re-specify it.
- Omitting `--base` only branches off the current branch while `base_branch` is
  unset in the config (it is). Setting `base_branch: main` would break that shortcut.
- Local-merge variant: `workmux merge feature-b --into feature-a`.

## Dashboard keys
| Key | Action | | Key | Action |
|-----|--------|-|-----|--------|
| `j`/`k` | Navigate | | `d` | Diff (WIP/review) |
| `Enter` | Go to agent | | `m` | Merge (from diff view) |
| `1`-`9` | Quick-jump | | `c` | Send commit to agent |
| `Tab` | Toggle last agent | | `i` | Input mode (type to agent) |
| `p` | Peek (stays open) | | `o` | Open PR in browser |
| `/` | Filter · `s` sort | | `:` | Command palette |
| `q`/`Esc` | Quit | | | |

Status icons in window names: 🤖 working · 💬 waiting · ✅ done.

## Working with gh-dash / PR review
gh-dash checkout (`C`, and our `T`/`O` bindings) runs `gh pr checkout` in the
**main repo checkout** — it switches that working dir's branch. workmux worktrees
are separate dirs, so they're independent **except at the main worktree**.

- **PR flow (team repos): no contention.** Review others' PRs in gh-dash; for your
  agents, push → PR → merge on GitHub → `workmux remove`. `remove` never touches
  the main worktree. This is the default flow — safe.
- **Caveat — local `workmux merge` while a PR is checked out.** `merge` into
  `master` uses the **main worktree** (unless `master` has its own worktree). If
  the main repo is mid-review on a PR branch, merge will yank it to `master` (and
  errors on a dirty tree). Only run local `workmux merge` from a clean main-repo
  state, or give `master` its own persistent worktree.
- **Branch-uniqueness:** a branch can't be checked out twice. Can't `gh pr checkout`
  a branch that's a live workmux worktree (and vice versa). Rare — reviews target
  others' branches; worktrees are your task branches.

## Files
- `config.yaml` — global defaults (managed here).
- Worktrees live at `<repo>/../<repo>__worktrees/<task>` — invisible to sesh.

## Gotchas
- **Must run inside tmux** — `workmux add` needs a running tmux server.
- **Dashboard empty?** You skipped `workmux setup` (no status hooks).
- **New worktree missing deps/`.env`?** Symlink/copy only fires where the source
  file exists — repos with no installed `node_modules` (e.g. `responsibid-client`)
  bootstrap empty; test dep-symlink on `responsibid-client-v2`/`-server`.

## Trial undo
```bash
brew uninstall workmux && rm -rf ~/.config/workmux
mv ~/.claude/settings.json.pre-workmux.bak ~/.claude/settings.json   # strip hooks
```
Then remove `dot_config/workmux/` from chezmoi.
