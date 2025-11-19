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
~/.local/bin/brew-upgrade.sh  # Updates all brew packages to latest versions
```

**How it works:**
- `packages.yml` defines what should be installed
- `run_onchange_darwin-install-packages.sh` auto-runs when packages.yml changes
- Upgrade script separately handles updating existing packages

## Neovim Configuration

**Setup:**
- Neovim config lives in separate repo: [emmandev/lazyvim](https://github.com/emmandev/lazyvim)
- Chezmoi syncs it to `~/.config/nvim` with weekly refresh (`refreshPeriod = "168h"`)
- Plugins managed by lazy.nvim (not chezmoi)

**Updating:**
```bash
# Update LazyVim framework + plugins (inside Neovim)
:Lazy update

# Update your personal config (if you made changes)
cd ~/.config/nvim && git pull  # or: chezmoi update
```

**Adding plugins:**
1. Edit files in `~/.config/nvim/lua/plugins/`
2. Commit and push to emmandev/lazyvim
3. Changes sync automatically via chezmoi refresh

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
├── scripts/
│   └── executable_brew-upgrade.sh      # Manual brew upgrade script
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
