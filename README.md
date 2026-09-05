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
│   ├── *.itermcolors       # iTerm2 colour schemes (imported by hand)
│   └── gh/config.yml       # ~/.config/gh/config.yml
└── home/                   # mirrors $HOME one-to-one
    ├── AGENTS.md           # ~/.claude/CLAUDE.md + ~/.codex/AGENTS.md
    ├── .claude/
    │   ├── settings.json
    │   ├── statusline-command.sh
    │   └── skills/
    └── .config/nvim/       # ~/.config/nvim  (whole dir symlinked)
        ├── init.lua
        ├── lazy-lock.json  # pinned plugin commits
        └── lua/
            ├── vim_config.lua   # editor options
            ├── keys.lua         # keymaps
            ├── plugin.lua       # lazy.nvim bootstrap
            └── plugins/         # one file per plugin group
```

## Neovim

Config adapted from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles).

Requires `ripgrep` and `fd` on `$PATH` — the Snacks pickers shell out to them,
so without `rg` the `<leader>s` grep fails only when you press the key:

```bash
brew install neovim ripgrep fd
```

`install.sh` warns if any of the three are missing.
Leader is `<Space>`; plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim)
and pinned in `lazy-lock.json`.

| Key | Action |
|---|---|
| `<leader>f` | Find files (Snacks picker) |
| `<leader>s` | Grep text |
| `<leader>b` | Buffers |
| `<leader>e` | File browser (oil.nvim) |
| `<leader>g` | Neogit |
| `gd` | Goto definition |
| `<Esc>` (normal) | Save the buffer |
| `<C-a>` | Select all |

The whole `nvim/` directory is symlinked, so lazy.nvim writes `lazy-lock.json`
straight back into this repo — commit it to pin plugin versions across machines.
After pulling on a new machine, run `nvim --headless "+Lazy! restore" +qa` to
check plugins out at the pinned commits.

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
