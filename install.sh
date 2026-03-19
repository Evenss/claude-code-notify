#!/bin/bash
# Claude Code Notification Hook Installer
# Usage: bash install.sh

set -e

HOOK_DIR="$HOME/.claude/hooks"
HOOK_FILE="$HOOK_DIR/notify.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Claude Code notification hook..."

# 1. Install terminal-notifier if missing (macOS)
if [[ "$(uname)" == "Darwin" ]] && ! command -v terminal-notifier &>/dev/null; then
    echo "==> Installing terminal-notifier (recommended for reliable notifications)..."
    if command -v brew &>/dev/null; then
        brew install terminal-notifier
    else
        echo "    Homebrew not found. Install terminal-notifier manually: brew install terminal-notifier"
        echo "    Falling back to osascript (may not show banners)."
    fi
fi

# 2. Copy hook script
mkdir -p "$HOOK_DIR"
cp "$SCRIPT_DIR/notify.sh" "$HOOK_FILE"
chmod +x "$HOOK_FILE"
echo "==> Hook script installed: $HOOK_FILE"

# 3. Configure settings.json
HOOK_CMD="bash $HOME/.claude/hooks/notify.sh"
HOOK_ENTRY="{\"type\":\"command\",\"command\":\"$HOOK_CMD\"}"
HOOK_MATCHER="{\"hooks\":[$HOOK_ENTRY]}"

if [[ ! -f "$SETTINGS_FILE" ]]; then
    # Create new settings.json with hooks
    python3 -c "
import json
settings = {
    'hooks': {
        'Stop': [{'hooks': [{'type': 'command', 'command': '$HOOK_CMD'}]}],
        'Notification': [{'hooks': [{'type': 'command', 'command': '$HOOK_CMD'}]}]
    }
}
print(json.dumps(settings, indent=2))
" > "$SETTINGS_FILE"
    echo "==> Created $SETTINGS_FILE with hook config."
else
    # Merge hooks into existing settings.json
    python3 -c "
import json, sys

with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)

hook_cmd = '$HOOK_CMD'
hook_entry = {'hooks': [{'type': 'command', 'command': hook_cmd}]}

if 'hooks' not in settings:
    settings['hooks'] = {}

changed = False
for event in ['Stop', 'Notification']:
    matchers = settings['hooks'].get(event, [])
    already = any(
        any(h.get('command') == hook_cmd for h in m.get('hooks', []))
        for m in matchers
    )
    if not already:
        matchers.append(hook_entry)
        settings['hooks'][event] = matchers
        changed = True

if changed:
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=2)
    print('updated')
else:
    print('exists')
" | while read -r result; do
        if [[ "$result" == "updated" ]]; then
            echo "==> Updated $SETTINGS_FILE with hook config."
        else
            echo "==> Hook config already exists in $SETTINGS_FILE."
        fi
    done
fi

# 4. Test
echo ""
echo "==> Testing notification..."
echo '{"hook_event_name":"Stop"}' | bash "$HOOK_FILE"
echo "==> Done! You should see a 'Claude Finished' notification."
echo ""
echo "Tip: If no notification appeared, run with debug:"
echo "  CLAUDE_NOTIFY_DEBUG=1 echo '{\"hook_event_name\":\"Stop\"}' | bash $HOOK_FILE"
echo "  cat /tmp/claude-code-notify.log"
