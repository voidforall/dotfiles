#!/bin/bash
# Claude Code statusLine
# Mirrors the powerline segments/colors of ~/.config/starship.toml
# (Catppuccin Macchiato theme): directory -> git branch/status ->
# model (Claude Code specific, replaces starship's language segments) -> time.
# Purely decorative elements from the starship prompt (the leading
# shaded block and the trailing prompt character) are omitted since
# they carry no information.

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(printf '%s' "$input" | jq -r '.model.display_name')
ctx_remaining=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')

# Powerline hard-divider arrow (matches the "" separators in starship.toml)
ARROW=$''

# Catppuccin Macchiato palette (same hex values as starship.toml)
LAVENDER="183;189;248"   # #b7bdf8
BLUE="138;173;244"       # #8aadf4
TEXT="202;211;245"       # #cad3f5
SURFACE1="73;77;100"     # #494d64
SURFACE0="54;58;79"      # #363a4f
MANTLE="30;32;48"        # #1e2030
GREEN="166;218;149"      # #a6da95

fgc() { printf '\033[38;2;%sm' "$1"; }
bgc() { printf '\033[48;2;%sm' "$1"; }
RESET='\033[0m'

# --- directory segment (fg text, bg blue) ---
dir="$cwd"
case "$dir" in
  "$HOME") dir="~" ;;
  "$HOME"/*) dir="~${dir#$HOME}" ;;
esac
IFS='/' read -r -a parts <<< "$dir"
count=${#parts[@]}
if [ "$count" -gt 3 ]; then
  trimmed="…"
  start=$((count - 3))
  for ((i = start; i < count; i++)); do
    trimmed="${trimmed}/${parts[$i]}"
  done
  dir="$trimmed"
fi
dir_text=" ${dir} "

# --- git segment (fg blue, bg surface1) ---
git_text=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  ab=""
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count "HEAD...${upstream}" 2>/dev/null)
    ahead=$(printf '%s' "$counts" | awk '{print $1}')
    behind=$(printf '%s' "$counts" | awk '{print $2}')
    ahead=${ahead:-0}
    behind=${behind:-0}
    [ "$ahead" -gt 0 ] 2>/dev/null && ab="${ab}⇡${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && ab="${ab}⇣${behind}"
  fi

  st=""
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  if [ -n "$porcelain" ]; then
    staged=$(printf '%s\n' "$porcelain" | grep -c '^[MADRC]')
    modified=$(printf '%s\n' "$porcelain" | grep -c '^.[MD]')
    untracked=$(printf '%s\n' "$porcelain" | grep -c '^??')
    conflicted=$(printf '%s\n' "$porcelain" | grep -c '^UU')
    [ "$staged" -gt 0 ] && st="${st}+${staged}"
    [ "$modified" -gt 0 ] && st="${st}!${modified}"
    [ "$conflicted" -gt 0 ] && st="${st}=${conflicted}"
    [ "$untracked" -gt 0 ] && st="${st}?${untracked}"
  fi

  git_text=" ⎇ ${branch}"
  [ -n "${st}${ab}" ] && git_text="${git_text} ${st}${ab}"
  git_text="${git_text} "
fi

# --- model segment (fg blue, bg surface0) -- Claude Code specific, ---
# --- replaces the nodejs/rust/golang/php language segments ---
model_text=" ✦ ${model} "

# --- context segment (fg green, bg surface1) ---
# --- remaining % of the context window for this session ---
ctx_text=""
if [ -n "$ctx_remaining" ]; then
  ctx_pct=$(printf '%.0f' "$ctx_remaining")
  ctx_text=" ⛁ ${ctx_pct}% left "
fi

# --- time segment (fg lavender, bg mantle) ---
time_text=" ⏱ $(date +%R) "

# --- assemble powerline segments dynamically (skip git segment if absent) ---
segments_bg=("$BLUE")
segments_fg=("$TEXT")
segments_text=("$dir_text")

if [ -n "$git_text" ]; then
  segments_bg+=("$SURFACE1"); segments_fg+=("$BLUE"); segments_text+=("$git_text")
fi
segments_bg+=("$SURFACE0"); segments_fg+=("$BLUE"); segments_text+=("$model_text")
if [ -n "$ctx_text" ]; then
  segments_bg+=("$SURFACE1"); segments_fg+=("$GREEN"); segments_text+=("$ctx_text")
fi
segments_bg+=("$MANTLE"); segments_fg+=("$LAVENDER"); segments_text+=("$time_text")

out=""
prev_bg="$LAVENDER"
n=${#segments_bg[@]}
for ((i = 0; i < n; i++)); do
  bg_i="${segments_bg[$i]}"
  fg_i="${segments_fg[$i]}"
  text_i="${segments_text[$i]}"
  out+="$(fgc "$prev_bg")$(bgc "$bg_i")${ARROW}"
  out+="$(bgc "$bg_i")$(fgc "$fg_i")${text_i}${RESET}"
  prev_bg="$bg_i"
done
out+="$(fgc "$prev_bg") ${ARROW}${RESET}"

printf '%b\n' "$out"
