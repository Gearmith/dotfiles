#!/usr/bin/env bash
# Claude Code statusline — Gruvbox Dark, flat badges with progress bars.
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
# Bars use plain Unicode block glyphs (█ ░); badges use Nerd Font (Font
# Awesome subset) icons — this pairing assumes a Nerd Font terminal
# (e.g. kitty + JetBrainsMono Nerd Font, per this dotfiles repo).

command -v jq >/dev/null 2>&1 || { printf 'statusline: jq not found'; exit 0; }

IN=$(cat)

# Gruvbox Dark palette (24-bit "R;G;B" triplets).
OVERLAY0="146;131;116"
CYAN="142;192;124"
YELLOW="250;189;47"
GREEN="184;187;38"
RED="251;73;52"
BLUE="131;165;152"
MAUVE="211;134;155"
PEACH="254;128;25"
SAPPHIRE="142;192;124"
LAVENDER="177;98;134"

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

# Flat badge: no background, no caps — bold text in the accent color.
badge() {
  local fg="$1" text="$2"
  printf '\033[1m\033[38;2;%sm%s\033[0m' "$fg" "$text"
}

# 8-cell bar of solid/empty Unicode blocks (U+2588 / U+2591) — filled cells
# in the severity color, empty cells dim, no background fill. Built with a
# loop, not `tr` — tr works byte-wise, and these are 3-byte UTF-8 characters,
# so `tr ' ' '█'` corrupts them into mojibake.
bar() {
  local pct="$1" fg="$2" width=8 filled empty i out=""
  filled=$(( pct * width / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  empty=$(( width - filled ))
  out+=$(printf '\033[38;2;%sm' "$fg")
  for (( i = 0; i < filled; i++ )); do out+="█"; done
  out+=$(printf '\033[38;2;%sm' "$OVERLAY0")
  for (( i = 0; i < empty; i++ )); do out+="░"; done
  out+=$'\033[0m'
  printf '%s' "$out"
}

# Bar + percentage, no background — just bold fg text in the severity color.
seg_bar() {
  local pct="$1" label="$2" fg="$3"
  printf '\033[1m\033[38;2;%sm%s \033[0m%s \033[1m\033[38;2;%sm%s%%\033[0m' \
    "$fg" "$label" "$(bar "$pct" "$fg")" "$fg" "$pct"
}

# Join segments with a dim " │ " separator. IFS only takes one character,
# so the join is done by hand.
join_segments() {
  local sep out="$1"
  sep=$(printf ' \033[38;2;%sm│\033[0m ' "$OVERLAY0")
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
SEGMENTS1=("$(badge "$CYAN" "$ICON_DIR $BASENAME")")

if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    DIRTY=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    [ "$DIRTY" -gt 0 ] && BRANCH="$BRANCH *$DIRTY"
    SEGMENTS1+=("$(badge "$YELLOW" "$ICON_GIT $BRANCH")")
  fi
fi

SEGMENTS1+=("$(badge "$MAUVE" "$ICON_MODEL $MODEL")")
[ -n "$STYLE" ] && SEGMENTS1+=("$(badge "$LAVENDER" "$ICON_STYLE $STYLE")")
[ -n "$VIM_MODE" ] && SEGMENTS1+=("$(badge "$SAPPHIRE" "$ICON_VIM $VIM_MODE")")

LINE1=$(join_segments "${SEGMENTS1[@]}")

# --- line 2: metrics for analysis ------------------------------------------

if [ -n "$CTX_PCT" ]; then
  CTX_INT=${CTX_PCT%.*}
  SEGMENTS2=("$(seg_bar "$CTX_INT" "$ICON_CTX ctx" "$(severity_color "$CTX_INT")")")
else
  SEGMENTS2=("$(printf '\033[1m\033[38;2;%sm%s\033[0m' "$OVERLAY0" "$ICON_CTX ctx n/a")")
fi

COST_FMT=$(printf '%.3f' "$COST")
SEGMENTS2+=("$(badge "$PEACH" "$ICON_COST \$$COST_FMT")")

DUR_S=$(( ${DUR_MS%.*} / 1000 ))
H=$(( DUR_S / 3600 )); M=$(( (DUR_S % 3600) / 60 )); S=$(( DUR_S % 60 ))
if [ "$H" -gt 0 ]; then DUR_FMT=$(printf '%dh%02dm' "$H" "$M"); else DUR_FMT=$(printf '%dm%02ds' "$M" "$S"); fi
SEGMENTS2+=("$(badge "$BLUE" "$ICON_DUR $DUR_FMT")")

if [ -n "$FIVE_H" ]; then
  FIVE_H_INT=${FIVE_H%.*}
  SEGMENTS2+=("$(seg_bar "$FIVE_H_INT" "$ICON_RATE 5h" "$(severity_color "$FIVE_H_INT")")")
fi
if [ -n "$SEVEN_D" ]; then
  SEVEN_D_INT=${SEVEN_D%.*}
  SEGMENTS2+=("$(seg_bar "$SEVEN_D_INT" "$ICON_RATE 7d" "$(severity_color "$SEVEN_D_INT")")")
fi

SEGMENTS2+=("$(printf '\033[38;2;%sm%s \033[0m\033[38;2;%sm+%s\033[0m \033[38;2;%sm-%s\033[0m' \
  "$OVERLAY0" "$ICON_LINES" "$GREEN" "$ADDED" "$RED" "$REMOVED")")

LINE2=$(join_segments "${SEGMENTS2[@]}")

# The spacer line holds one space: a truly empty line may be dropped.
SPACER=' '
printf '%s\n%s\n%s' "$LINE1" "$SPACER" "$LINE2"
