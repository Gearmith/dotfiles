#!/usr/bin/env bash
# Tracks active Agent-tool subagents per Claude Code session, so the
# statusline can show a live count + short description on its 3rd line.
#
# Wire up in ~/.claude/settings.json:
#   "PostToolUse":  [{"matcher": "Agent", "hooks": [{"type":"command",
#     "command": "bash \"$HOME/dotfiles/.config/claude/hooks/track-agents.sh\" start"}]}]
#   "SubagentStop": [{"matcher": "", "hooks": [{"type":"command",
#     "command": "bash \"$HOME/dotfiles/.config/claude/hooks/track-agents.sh\" stop"}]}]
#   "SessionStart": [{"matcher": "startup|resume|clear|compact", "hooks": [{"type":"command",
#     "command": "bash \"$HOME/dotfiles/.config/claude/hooks/track-agents.sh\" reset"}]}]
#
# State: one JSON array per session at ~/.claude/.active-agents/<session_id>.json
# — read by statusline.sh, written here. Values from the hook payload (agent
# description, type) are untrusted-ish free text, so they only ever reach jq
# via --arg (never interpolated into a shell string) and get length-capped.

command -v jq >/dev/null 2>&1 || exit 0

MODE="${1:-}"
IN=$(cat)

SESSION_ID=$(jq -r '.session_id // empty' <<<"$IN")
case "$SESSION_ID" in
  ''|*[!A-Za-z0-9_-]*) exit 0 ;;
esac
[ "${#SESSION_ID}" -gt 128 ] && exit 0

STATE_DIR="$HOME/.claude/.active-agents"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$SESSION_ID.json"
LOCK_FILE="$STATE_FILE.lock"

[ -f "$STATE_FILE" ] || printf '[]' > "$STATE_FILE"

case "$MODE" in
  reset)
    printf '[]' > "$STATE_FILE"
    ;;

  start)
    IS_ASYNC=$(jq -r '.tool_response.isAsync // false' <<<"$IN")
    [ "$IS_ASYNC" = "true" ] || exit 0
    AGENT_ID=$(jq -r '.tool_response.agentId // empty' <<<"$IN")
    [ -z "$AGENT_ID" ] && exit 0
    DESC=$(jq -r '.tool_input.description // .tool_response.description // "agent"' <<<"$IN")
    TYPE=$(jq -r '.tool_input.subagent_type // "general-purpose"' <<<"$IN")
    NOW=$(date +%s)

    exec 200>"$LOCK_FILE"
    flock 200
    jq --arg id "$AGENT_ID" --arg desc "$DESC" --arg type "$TYPE" --argjson now "$NOW" \
      '. + [{id: $id, description: ($desc[0:60]), agent_type: $type, started_at: $now}]' \
      "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    flock -u 200
    ;;

  stop)
    AGENT_ID=$(jq -r '.agent_id // empty' <<<"$IN")
    [ -z "$AGENT_ID" ] && exit 0

    exec 200>"$LOCK_FILE"
    flock 200
    jq --arg id "$AGENT_ID" '[.[] | select(.id != $id)]' \
      "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    flock -u 200
    ;;
esac

exit 0
