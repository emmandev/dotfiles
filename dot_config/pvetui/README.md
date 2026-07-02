# pvetui cheatsheet

TUI for Proxmox. Creds come from 1Password (API token) injected at runtime via
`op run` — nothing secret is stored in `config.yml`.

## Launch
```bash
pvetui                # alias: op run --env-file=~/.config/pvetui/pvetui.env -- pvetui
```
Or open the **`homelab`** sesh session (runs the same command).

## Keys
| Key | Action | | Key | Action |
|-----|--------|-|-----|--------|
| `?` | Help (full keymap) | | `N` | Nodes view |
| `j`/`k` | Down / up | | `G` | Guests view |
| `Enter`/`Esc` | Descend / back | | `T` | Tasks view |
| `]`/`[` | Cycle views | | `S` | Storage view |
| `/` | Search / filter | | `s` | SSH shell (node/guest) |
| `m` | Context menu (all actions) | | `v` | Console (VNC) |
| `Ctrl+g`/`Esc` | Global menu | | `x` | Stop/cancel task |
| `Ctrl+r` | Refresh · `a` auto | | `q` | Quit |

> `m` is the discovery tool: highlight anything → menu shows every action + its key.

## SSH into a guest
1. `G` → highlight guest (`/` to filter) → **`s`**.
2. Exit shell (`exit`/`Ctrl-d`) returns to pvetui.

SSH uses `ssh_user`/`vm_ssh_user` (both `root`) + your **1Password SSH agent** keys.
Needs: guest running, `sshd` up, your key in its `authorized_keys`. VMs also need the
**QEMU guest agent** (so pvetui can find their IP).

## Files
- `config.yml` — profile, keybindings (no secrets).
- `pvetui.env` — `op://` token references, resolved at runtime.

## Gotchas
- **macOS Sequoia:** grant the terminal (Ghostty) **Local Network** access
  (System Settings ▸ Privacy & Security ▸ Local Network) or CLI gets `no route to host`.
- **Token shows "loading" forever:** disable **Privilege Separation** on the token, or
  grant it a role (Datacenter ▸ Permissions ▸ API Tokens).
- **`Alt` = Option**, which Aerospace grabs — hence page keys are `N/G/T/S`, not `Alt+1..4`.
