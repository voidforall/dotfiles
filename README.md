# dotfiles

Personal dotfiles for macOS — shell, git, starship, GitHub CLI, and Claude Code.

## Structure

```
dotfiles/
├── install.sh              # Symlink installer
├── shell/
│   ├── zshrc               # ~/.zshrc  (zsh + oh-my-zsh + starship)
│   ├── zprofile            # ~/.zprofile  (LLVM paths)
│   ├── zshenv              # ~/.zshenv  (Rust/cargo)
│   └── profile             # ~/.profile  (Rust/cargo for login shells)
├── git/
│   ├── gitconfig           # ~/.gitconfig
│   └── gitignore_global    # ~/.config/git/ignore
├── config/
│   ├── starship.toml       # ~/.config/starship.toml
│   └── gh/
│       └── config.yml      # ~/.config/gh/config.yml
└── claude/
    ├── settings.json       # ~/.claude/settings.json
    └── rules/
        ├── common/         # Language-agnostic rules
        └── typescript/     # TS/JS-specific rules
```

## Install

```bash
git clone https://github.com/voidforall/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Preview what will happen first:

```bash
./install.sh --dry-run
```

`install.sh` creates symlinks from this repo into `$HOME`. Any existing file is backed up as `<file>.bak` before being replaced.

## Machine-local config

Secrets and machine-specific settings go in untracked local files that are sourced automatically:

| Local file | Sourced by |
|---|---|
| `~/.zshrc.local` | `~/.zshrc` |
| `~/.zprofile.local` | `~/.zprofile` |

Example `~/.zshrc.local`:

```sh
export OPENAI_API_KEY="sk-..."
export AWS_PROFILE="my-profile"
# any other machine-specific or secret env vars
```

## Syncing changes

After editing any file in this repo:

```bash
cd ~/dotfiles
git add -p          # review changes
git commit -m "..."
git push
```

On a new machine / after pulling changes, just run `./install.sh` again — symlinks are idempotent.

## What is NOT tracked

- `~/.git-credentials` — plain-text git tokens (use `osxkeychain` instead)
- `~/.aws/credentials` — AWS keys
- `~/.zshrc.local` / `~/.zprofile.local` — machine-specific secrets
- `~/.claude/settings.local.json` — Claude local overrides
