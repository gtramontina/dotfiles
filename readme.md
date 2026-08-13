# .dotfilez

System configuration managed with [Nix](https://nixos.org/), [home-manager](https://github.com/nix-community/home-manager), and [nix-darwin](https://github.com/LnL7/nix-darwin).

## Machines

| Machine | Hostname | OS | Profile |
|---|---|---|---|
| Personal Mac | `orion` | macOS | personal |
| Work Mac | `phoenix` | macOS | work |
| Desktop | `cygnus` | Omarchy (Arch) | personal |

## One-liner

```shell
curl -Ls https://raw.githubusercontent.com/gtramontina/dotfilez/main/scripts/install.sh | bash
```

The installer is interactive and idempotent. It clones the repo, asks for hostname/profile/git identity, and applies the configuration.

## Usage

```shell
# Apply configuration (build + switch)
make switch

# Update flake inputs and apply
make update

# Build without applying
make build
```

`make switch` detects the OS and hostname automatically, selecting the right flake target.

## Structure

```
├── flake.nix              # all configurations (edit here to add machines)
├── Makefile               # switch / build / update
├── modules/
│   ├── darwin.nix         # macOS system settings (nix-darwin)
│   ├── homebrew.nix       # macOS packages (casks + brews), profile-aware
│   ├── linux.nix          # Linux-specific settings
│   ├── home/              # cross-platform dotfiles (shared by all machines)
│   │   ├── default.nix    # shared core: packages, session vars
│   │   ├── git.nix        # git config (identity set by profile)
│   │   ├── zsh.nix        # zsh with platform guards
│   │   ├── gpg.nix        # gpg with platform guards
│   │   ├── ghostty.nix    # ghostty with platform guards
│   │   ├── opencode.nix
│   │   ├── zed-editor.nix # zed with platform guards
│   │   ├── hunk.nix
│   │   └── vscode.nix
│   └── profiles/
│       ├── personal.nix   # personal git identity
│       └── work.nix       # work git identity
├── hosts/                 # one per machine (filename = hostname)
│   ├── orion.nix
│   ├── phoenix.nix
│   └── cygnus.nix
├── scripts/
│   ├── install.sh         # interactive installer
│   └── setup.sh           # idempotent setup (installs nix, runs make switch)
```

## How it works

**Three axes of variation:**

- **Platform** (macOS vs Linux) — handled by `stdenv.isDarwin` / `isLinux` guards in modules. `darwin.nix` and `homebrew.nix` are macOS-only. `linux.nix` is Linux-only.
- **Profile** (personal vs work) — handled by profile modules that set git identity. The `homebrew.nix` module is profile-aware and adds work-only casks when `profile == "work"`.
- **Host** (which machine) — each host file composes `modules/home` (shared core) + a profile + platform-specific modules. Hostnames match flake config names for auto-detection.

**Shared core:** All hosts share the same `modules/home/` configuration. Platform guards within each module handle OS-specific behavior. A change to any shared module applies to all machines on next `make switch`.

## Adding a new machine

1. Pick a hostname and set it on the machine (`scutil --set HostName` on macOS, `hostnamectl set-hostname` on Linux)
2. Create `hosts/<hostname>.nix` (copy from an existing host, adjust profile)
3. Add an entry to `flake.nix` (`mkDarwin` or `mkHome`)
4. Run the one-liner installer on the machine
