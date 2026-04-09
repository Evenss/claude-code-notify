#!/bin/bash
# Claude Code Notification Hook
# Sends macOS notifications when Claude needs attention

# Skip if notifications disabled
[[ "$CLAUDE_NOTIFY_DISABLED" == "1" ]] && exit 0

# Detect which terminal is running Claude Code
# Only skip notification if user is in THIS terminal (not other terminals)
get_claude_terminal_bundle_id() {
    case "${TERM_PROGRAM:-}" in
        WarpTerminal)   echo "dev.warp.Warp-Stable" ;;
        iTerm.app)      echo "com.googlecode.iterm2" ;;
        Apple_Terminal) echo "com.apple.Terminal" ;;
        vscode)         echo "com.microsoft.VSCode" ;;
        Alacritty)      echo "io.alacritty" ;;
        kitty)          echo "net.kovidgoyal.kitty" ;;
        Hyper)          echo "co.zeit.hyper" ;;
        WezTerm)        echo "com.github.wez.wezterm" ;;
        Ghostty)        echo "com.mitchellh.ghostty" ;;
        *)
            # Try to detect from process tree
            osascript -e 'tell application "System Events" to get bundle identifier of (first process whose unix id is '"$$"')' 2>/dev/null
            ;;
    esac
}

# Skip if user is already in the terminal running Claude Code
# This prevents notifications when user is actively using Claude Code
claude_terminal=$(get_claude_terminal_bundle_id)
active_app=$(osascript -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true' 2>/dev/null)

if [[ -n "$claude_terminal" && "$active_app" == "$claude_terminal" ]]; then
    if [[ "$CLAUDE_NOTIFY_DEBUG" == "1" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipped: Claude's terminal is active ($claude_terminal)" >> /tmp/claude-code-notify.log
    fi
    exit 0
fi

# Read input from stdin
input=$(cat)

# Debug logging (enable with CLAUDE_NOTIFY_DEBUG=1)
if [[ "$CLAUDE_NOTIFY_DEBUG" == "1" ]]; then
    {
        echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="
        echo "Raw input: $input"
    } >> /tmp/claude-code-notify.log
fi

# Parse JSON value - tries python3 first (robust), falls back to grep/sed
get_json_value() {
    local key="$1"
    local val
    val=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$key',''))" 2>/dev/null)
    if [[ $? -ne 0 || -z "$val" ]]; then
        val=$(echo "$input" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*: *"\([^"]*\)".*/\1/' | head -1)
    fi
    echo "$val"
}

# Escape special characters for AppleScript
escape_for_applescript() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

event=$(get_json_value "hook_event_name")
notification_type=$(get_json_value "notification_type")
message=$(get_json_value "message")

if [[ "$CLAUDE_NOTIFY_DEBUG" == "1" ]]; then
    {
        echo "Parsed: event=$event notification_type=$notification_type message=$message"
    } >> /tmp/claude-code-notify.log
fi

# Default sound (configurable via CLAUDE_NOTIFY_SOUND)
sound="${CLAUDE_NOTIFY_SOUND:-Glass}"

case "$event" in
  "Stop")
    title="Claude Finished"
    body="Ready for next instruction"
    ;;
  "Notification")
    case "$notification_type" in
      "permission_prompt")
        title="Permission Needed"
        body="${message:-Claude needs permission to continue}"
        ;;
      "idle_prompt")
        title="Waiting for You"
        body="Claude is idle and waiting for input"
        ;;
      "elicitation_dialog")
        title="Input Needed"
        body="${message:-Claude has a question}"
        ;;
      "auth_success")
        title="Auth Complete"
        body="Authentication successful"
        ;;
      *)
        title="Claude Code"
        body="${message:-Notification}"
        ;;
    esac
    ;;
  *)
    title="Claude Code"
    body="${message:-Needs attention}"
    ;;
esac

# Detect terminal app bundle ID for click-to-activate
get_terminal_bundle_id() {
    case "${TERM_PROGRAM:-}" in
        WarpTerminal)  echo "dev.warp.Warp-Stable" ;;
        iTerm.app)     echo "com.googlecode.iterm2" ;;
        Apple_Terminal) echo "com.apple.Terminal" ;;
        vscode)        echo "com.microsoft.VSCode" ;;
        *)
            # Try to detect from parent process
            local parent_app
            parent_app=$(osascript -e 'tell application "System Events" to get bundle identifier of (first process whose unix id is '"$$"')' 2>/dev/null)
            echo "${parent_app:-}"
            ;;
    esac
}

# Send macOS notification via terminal-notifier (fallback to osascript)
if command -v terminal-notifier &>/dev/null; then
    activate_id=$(get_terminal_bundle_id)
    activate_args=()
    [[ -n "$activate_id" ]] && activate_args=(-activate "$activate_id")
    terminal-notifier -title "$title" -message "$body" -sound "$sound" -group "claude-code" "${activate_args[@]}" 2>/dev/null
    rc=$?
else
    title=$(escape_for_applescript "$title")
    body=$(escape_for_applescript "$body")
    sound=$(escape_for_applescript "$sound")
    osascript -e "display notification \"$body\" with title \"$title\" sound name \"$sound\"" 2>/dev/null
    rc=$?
fi

if [[ "$CLAUDE_NOTIFY_DEBUG" == "1" ]]; then
    echo "Notification sent: title='$title' body='$body' exit=$rc" >> /tmp/claude-code-notify.log
fi

exit 0
