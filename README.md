# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), using a two-repository architecture for modular configuration management.

## Overview

This repository manages system configurations across macOS machines. Neovim configuration is maintained in a separate repository ([emmandev/lazyvim](https://github.com/emmandev/lazyvim)) and synced via chezmoi's external resources feature.

**Architecture:**
- `emmandev/dotfiles` → Shell configs, tool settings, package lists
- `emmandev/lazyvim` → Neovim configuration (managed separately)

## Quick Start

```bash
# Install chezmoi and apply dotfiles
brew install chezmoi
chezmoi init --apply emmandev

# On subsequent updates
chezmoi update && chezmoi apply
```

## Package Management

**Adding/removing packages:**
```bash
chezmoi edit ~/.local/share/chezmoi/.chezmoidata/packages.yml
# Add package to brews/casks list
chezmoi apply  # Auto-installs new packages
```

**Upgrading packages:**
```bash
brew-upgrade.sh  # Updates all brew packages to latest versions
```

**Removing unlisted packages:**
```bash
brew-cleanup.sh  # Removes packages not in packages.yml
```

**How it works:**
- `packages.yml` defines what should be installed
- `run_onchange_darwin-install-packages.sh` auto-runs when packages.yml changes
- Upgrade script separately handles updating existing packages

## Neovim Configuration

**Setup:**
- Neovim config lives in separate repo: [emmandev/lazyvim](https://github.com/emmandev/lazyvim)
- Chezmoi syncs it to `~/.config/nvim` as a `git-repo` external with weekly refresh (`refreshPeriod = "168h"`)
- The remote is SSH (`git@github.com:emmandev/lazyvim.git`), so push/clone use the 1Password SSH agent
- Plugins managed by lazy.nvim (not chezmoi); plugin versions are pinned in `lazy-lock.json`, which **is** tracked in the repo

**`~/.config/nvim` is a live git repo.** Your config and plugin versions are tracked
there, not in this dotfiles repo — chezmoi only clones/refreshes it. The external pulls
with `--ff-only`, so it never merges or rewrites your local work: **always push your
local commits before `chezmoi update`**, or the refresh will stop on divergence (your
work stays intact).

**Changing config / adding a plugin:**
```bash
# Edit files in ~/.config/nvim/lua/plugins/ or lua/config/
cd ~/.config/nvim
git add -A && git commit -m "feat: ..." && git push
```

**Updating plugin versions (reproducible across machines):**
```bash
# Inside Neovim — rewrites lazy-lock.json
:Lazy update     # or :Lazy sync

# Commit the new lock file so other machines get the same versions
cd ~/.config/nvim
git add lazy-lock.json && git commit -m "build: update lazy-lock" && git push
```

**Pulling onto another machine:**
```bash
chezmoi update   # fast-forwards ~/.config/nvim (push local commits first)
```

## 1Password Integration

**SSH Keys:**
```bash
# Add to ~/.ssh/config (managed locally, not in chezmoi)
Host *
	IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```
- Keys stored in 1Password are automatically available
- Add SSH keys via 1Password app → SSH Keys section

**Environment Variables with 1Password:**

Using [1Password Environments](https://developer.1password.com/docs/environments/):

```bash
# 1. Create secrets.yaml from example
cp secrets.yaml.example .chezmoidata/secrets.yaml
# Fill in your vault/item names

# 2. Templates use variables from secrets.yaml
# Example .env.tmpl:
AWS_ACCESS_KEY_ID="op://{{ .project.vault }}/{{ .project.env.aws_item }}/field name"

# 3. Use aliases with op run
alias my-env='op run --env-file=$HOME/.config/project/env.env --'
my-env aws s3 ls
```

**Secrets in config files (chezmoi templates):**

Some tools read a secret from a config *file* rather than an env var. Template the file and
pull the value with `onepasswordRead`, so it comes from 1Password at `chezmoi apply` time
and is never committed:

```
field: "{{ onepasswordRead (printf "op://%s/%s/<field>" .tool.vault .tool.item) }}"
```

- Store the secret in 1Password; put the vault/item in `secrets.yaml` (git-ignored)
- The source template holds only the `op://` reference — never the secret
- `chezmoi apply` renders the file locally; `op` must be signed in at apply time

**Setup:**
1. Install 1Password desktop app and enable SSH agent
2. Add the IdentityAgent line to your local `~/.ssh/config`
3. Copy `secrets.yaml.example` to `.chezmoidata/secrets.yaml`
4. Fill in your 1Password vault and item names
5. Create `.env.tmpl` files with templated secret references
6. Add aliases to `.zshrc` for convenience

## Common Commands

| Command | Purpose |
|---------|---------|
| `chezmoi apply` | Apply dotfile changes to system |
| `chezmoi edit <file>` | Edit source file (e.g., `chezmoi edit ~/.zshrc`) |
| `chezmoi update` | Pull latest from external repos (oh-my-zsh, nvim, etc.) |
| `chezmoi diff` | Preview what will change before applying |
| `chezmoi cd` | Navigate to source directory |

## Managed Configurations

**Shell:**
- zsh (with oh-my-zsh, powerlevel10k, autosuggestions, syntax-highlighting)

**Development:**
- Neovim (LazyVim) - external repo
- tmux + tpm plugins
- Git configuration
- Lazygit (git TUI)
- JiraTUI (Jira client)

**Tools:**
- Aerospace (window manager)
- Ghostty (terminal)
- Yazi (file manager)
- Sesh (tmux session manager)

**External Resources (auto-updated):**
- oh-my-zsh (weekly)
- zsh plugins (weekly)
- Neovim config (weekly)
- tmux plugins

## Repository Structure

```
~/.local/share/chezmoi/
├── .chezmoidata/
│   └── packages.yml                    # Homebrew package definitions
├── .chezmoiexternal.toml               # External repo references
├── dot_local/
│   └── bin/
│       ├── executable_brew-upgrade.sh      # Manual brew upgrade script
│       └── executable_brew-cleanup.tmpl.sh # Removes unlisted packages
├── dot_config/
│   ├── ghostty/                        # Terminal config
│   ├── sesh/                           # Session manager
│   ├── tmux/                           # Tmux configuration
│   └── yazi/                           # File manager
├── dot_zshrc                           # Zsh configuration
├── dot_aerospace.toml                  # Window manager config
└── run_onchange_darwin-install-packages.sh.tmpl
```

## Troubleshooting

**Check what will change before applying:**
```bash
chezmoi diff
```

**Force re-run package installation:**
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

**Verify external resources:**
```bash
chezmoi update --verbose
```
