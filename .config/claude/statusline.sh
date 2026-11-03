#!/usr/bin/env bash
# Claude Code statusline — GitHub Dark, muted labels, one accent, state-only color.
#
# Wire up in ~/.claude/settings.json:
#   "statusLine": {
#     "type": "command",
#     "command": "bash \"$HOME/dotfiles/.config/claude/statusline.sh\""
#   }
#
# Claude Code writes the session JSON to stdin and reads stdout back.
# Requires jq (brew install jq / apt install jq).
#
# Bars use plain Unicode block glyphs (█ ░); icons use Nerd Font (Font
# Awesome subset) icons — this pairing assumes a Nerd Font terminal
# (e.g. kitty + JetBrainsMono Nerd Font, per this dotfiles repo).

command -v jq >/dev/null 2>&1 || { printf 'statusline: jq not found'; exit 0; }

IN=$(cat)

# GitHub Dark palette (24-bit "R;G;B" triplets).
# Hierarchy: muted gray labels, foreground values, one blue accent for
# identity (line 1), color otherwise reserved for state (severity, +/-).
# Contrast vs bg #0d1117: FG 12:1, MUTED 6.15:1, TRACK 4.12:1.
FG="201;209;217"      # #c9d1d9 values
MUTED="139;148;158"   # #8b949e labels
TRACK="110;118;129"   # #6e7681 separators + empty bar cells
BLUE="88;166;255"     # #58a6ff accent
YELLOW="227;179;65"   # #e3b341
GREEN="63;185;80"     # #3fb950
RED="255;123;114"     # #ff7b72

# Nerd Font (Font Awesome subset) icons, built via bash's $'\uXXXX' escape —
# not hand-computed UTF-8 bytes, which is what corrupted an earlier attempt.
ICON_DIR=$''    # folder
ICON_GIT=$''    # code-fork
ICON_MODEL=$''  # cogs
ICON_STYLE=$''  # paint-brush
ICON_VIM=$''    # keyboard
ICON_CTX=$''    # tachometer
ICON_COST=$''   # dollar
ICON_DUR=$''    # clock-o
ICON_RATE=$''   # bolt
ICON_LINES=$''  # code

# Colored text helpers: txt <rgb> <text> (plain), bold only for state values.
txt() { printf '\033[38;2;%sm%s\033[0m' "$1" "$2"; }

# Identity segment: blue icon, foreground value.
ident() { printf '%s %s' "$(txt "$BLUE" "$1")" "$(txt "$FG" "$2")"; }

# Labeled metric: muted icon+label, foreground value.
metric() { printf '%s %s' "$(txt "$MUTED" "$1")" "$(txt "$FG" "$2")"; }

# 8-cell bar of solid/empty Unicode blocks (U+2588 / U+2591) — filled cells
# in the severity color, empty track in TRACK (#6e7681, 4.12:1), no background
# fill. Built with a loop, not `tr` — tr works byte-wise, and these are 3-byte
# UTF-8 characters, so `tr ' ' '█'` corrupts them into mojibake.
bar() {
  local pct="$1" fg="$2" width=8 filled empty i out=""
  filled=$(( pct * width / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  empty=$(( width - filled ))
  out+=$(printf '\033[38;2;%sm' "$fg")
  for (( i = 0; i < filled; i++ )); do out+="█"; done
  out+=$(printf '\033[38;2;%sm' "$TRACK")
  for (( i = 0; i < empty; i++ )); do out+="░"; done
  out+=$'\033[0m'
  printf '%s' "$out"
}

# Severity metric: muted label, optional bar (only when show_bar=1), then the
# percentage in the severity color.
seg_bar() {
  local pct="$1" label="$2" fg="$3" show_bar="$4" out
  out=$(txt "$MUTED" "$label")
  [ "$show_bar" = 1 ] && out+=" $(bar "$pct" "$fg")"
  out+=$(printf ' \033[1m\033[38;2;%sm%s%%\033[0m' "$fg" "$pct")
  printf '%s' "$out"
}

# Join segments with a dim " · " separator. IFS only takes one character,
# so the join is done by hand.
join_segments() {
  local sep out="$1"
  sep=$(printf ' \033[38;2;%sm·\033[0m ' "$TRACK")
  shift
  for seg in "$@"; do out+="$sep$seg"; done
  printf '%s' "$out"
}

severity_color() {
  local pct="$1"
  if [ "$pct" -ge 80 ]; then printf '%s' "$RED"
  elif [ "$pct" -ge 50 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

jqr() { jq -r "$1 // empty" <<<"$IN"; }

DIR=$(jqr '.workspace.current_dir // .cwd')
MODEL=$(jqr '.model.display_name // .model.id')
STYLE=$(jqr '.output_style.name')
VIM_MODE=$(jqr '.vim.mode')
COST=$(jqr '.cost.total_cost_usd')
DUR_MS=$(jqr '.cost.total_duration_ms')
ADDED=$(jqr '.cost.total_lines_added')
REMOVED=$(jqr '.cost.total_lines_removed')
CTX_PCT=$(jqr '.context_window.used_percentage')
FIVE_H=$(jqr '.rate_limits.five_hour.used_percentage')
SEVEN_D=$(jqr '.rate_limits.seven_day.used_percentage')

: "${DIR:=$PWD}" "${MODEL:=?}" "${COST:=0}" "${DUR_MS:=0}" "${ADDED:=0}" "${REMOVED:=0}"

# --- line 1: where / what ---------------------------------------------------

BASENAME="${DIR##*/}"
[ "$DIR" = "$HOME" ] && BASENAME="~"
SEGMENTS1=("$(ident "$ICON_DIR" "$BASENAME")")

if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    DIRTY=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    BRANCH_SEG=$(ident "$ICON_GIT" "$BRANCH")
    # Dirty count keeps green: it encodes state.
    [ "$DIRTY" -gt 0 ] && BRANCH_SEG+=" $(txt "$GREEN" "*$DIRTY")"
    SEGMENTS1+=("$BRANCH_SEG")
  fi
fi

SEGMENTS1+=("$(ident "$ICON_MODEL" "$MODEL")")
[ -n "$STYLE" ] && SEGMENTS1+=("$(ident "$ICON_STYLE" "$STYLE")")
[ -n "$VIM_MODE" ] && SEGMENTS1+=("$(ident "$ICON_VIM" "$VIM_MODE")")

LINE1=$(join_segments "${SEGMENTS1[@]}")

# --- line 2: metrics for analysis ------------------------------------------

if [ -n "$CTX_PCT" ]; then
  CTX_INT=${CTX_PCT%.*}
  SEGMENTS2=("$(seg_bar "$CTX_INT" "$ICON_CTX ctx" "$(severity_color "$CTX_INT")" 1)")
else
  SEGMENTS2=("$(txt "$MUTED" "$ICON_CTX ctx n/a")")
fi

COST_FMT=$(printf '%.3f' "$COST")
SEGMENTS2+=("$(metric "$ICON_COST" "\$$COST_FMT")")

DUR_S=$(( ${DUR_MS%.*} / 1000 ))
H=$(( DUR_S / 3600 )); M=$(( (DUR_S % 3600) / 60 )); S=$(( DUR_S % 60 ))
if [ "$H" -gt 0 ]; then DUR_FMT=$(printf '%dh%02dm' "$H" "$M"); else DUR_FMT=$(printf '%dm%02ds' "$M" "$S"); fi
SEGMENTS2+=("$(metric "$ICON_DUR" "$DUR_FMT")")

if [ -n "$FIVE_H" ]; then
  FIVE_H_INT=${FIVE_H%.*}
  SEGMENTS2+=("$(seg_bar "$FIVE_H_INT" "$ICON_RATE 5h" "$(severity_color "$FIVE_H_INT")" "$(( FIVE_H_INT >= 50 ))")")
fi
if [ -n "$SEVEN_D" ]; then
  SEVEN_D_INT=${SEVEN_D%.*}
  SEGMENTS2+=("$(seg_bar "$SEVEN_D_INT" "$ICON_RATE 7d" "$(severity_color "$SEVEN_D_INT")" "$(( SEVEN_D_INT >= 50 ))")")
fi

SEGMENTS2+=("$(printf '\033[38;2;%sm%s \033[0m\033[38;2;%sm+%s\033[0m \033[38;2;%sm-%s\033[0m' \
  "$MUTED" "$ICON_LINES" "$GREEN" "$ADDED" "$RED" "$REMOVED")")

LINE2=$(join_segments "${SEGMENTS2[@]}")

# --- layout: one line when it fits, else two ----------------------------------

# Visible width: strip SGR escapes, then count characters. Icons (Nerd Font
# Mono) and bar blocks are one cell each, so the character count is the width.
visible_width() {
  local s="$1" esc=$'\033\\[[0-9;]*m'
  while [[ $s =~ $esc ]]; do s=${s/"${BASH_REMATCH[0]}"/}; done
  # ${#s} counts characters, not bytes, only under a UTF-8 locale.
  local LC_ALL=C.UTF-8
  printf '%s' "${#s}"
}

ONE_LINE="$LINE1$(printf ' \033[38;2;%sm·\033[0m ' "$TRACK")$LINE2"

# Claude Code sets COLUMNS to the terminal width before running this script.
# Keep a small margin for its left padding and any notification it shows.
COLS=${COLUMNS:-0}
MARGIN=4

if [ "$COLS" -gt 0 ] && [ "$(visible_width "$ONE_LINE")" -le $(( COLS - MARGIN )) ]; then
  printf '%s' "$ONE_LINE"
else
  # The spacer line holds one space: a truly empty line may be dropped.
  SPACER=' '
  printf '%s\n%s\n%s' "$LINE1" "$SPACER" "$LINE2"
fi
