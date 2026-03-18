# claude-notify

macOS desktop notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

When Claude finishes a task, needs permission, or is waiting for your input, you'll get a native macOS notification — with sound and click-to-focus support.

## Features

- **Task completion alerts** — get notified the moment Claude finishes working
- **Permission prompts** — know immediately when Claude needs approval to proceed
- **Idle/input reminders** — don't leave Claude waiting without realizing it
- **Click to focus** — clicking the notification brings your terminal to the foreground
- **Auto-detect terminal** — works with Warp, iTerm2, Terminal.app, VS Code, and more
- **Zero dependencies** — pure bash script, uses `terminal-notifier` (recommended) or built-in `osascript`
- **Debug mode** — built-in logging for troubleshooting

## Quick Install

```bash
git clone https://github.com/Evenss/claude-notify.git
cd claude-notify
bash install.sh
```

The installer will:
1. Install `terminal-notifier` via Homebrew (if not already installed)
2. Copy the hook script to `~/.claude/hooks/notify.sh`
3. Add Stop and Notification hooks to `~/.claude/settings.json` (preserves existing config)
4. Send a test notification to verify it works

## Manual Install

1. Install terminal-notifier (recommended for reliable notifications + click-to-focus):
   ```bash
   brew install terminal-notifier
   ```

2. Copy the hook script:
   ```bash
   mkdir -p ~/.claude/hooks
   cp notify.sh ~/.claude/hooks/notify.sh
   chmod +x ~/.claude/hooks/notify.sh
   ```

3. Add hooks to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash /Users/yourname/.claude/hooks/notify.sh"
             }
           ]
         }
       ],
       "Notification": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash /Users/yourname/.claude/hooks/notify.sh"
             }
           ]
         }
       ]
     }
   }
   ```

   > **Note:** Use absolute path (`/Users/yourname/...`), not `~`. Tilde may not expand in Claude Code's hook execution context.

## Notification Events

| Event | Notification Title | Trigger |
|-------|-------------------|---------|
| Stop | Claude Finished | Claude completes a task and is ready for next instruction |
| Notification: permission_prompt | Permission Needed | Claude needs your approval to run a tool (e.g., file edit, shell command) |
| Notification: idle_prompt | Waiting for You | Claude is idle, waiting for your input |
| Notification: elicitation_dialog | Input Needed | Claude has a question and needs your answer |
| Notification: auth_success | Auth Complete | Authentication flow completed successfully |

## Click to Focus

When using `terminal-notifier`, clicking on a notification will automatically bring your terminal app to the foreground. The following terminals are auto-detected:

| Terminal | Bundle ID |
|----------|-----------|
| Warp | `dev.warp.Warp-Stable` |
| iTerm2 | `com.googlecode.iterm2` |
| Terminal.app | `com.apple.Terminal` |
| VS Code | `com.microsoft.VSCode` |

Other terminals are detected automatically via the system process tree.

## Configuration

Set these environment variables in `~/.claude/settings.json` under `"env"`:

```json
{
  "env": {
    "CLAUDE_NOTIFY_SOUND": "Ping"
  }
}
```

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_NOTIFY_DISABLED` | — | Set to `1` to disable all notifications |
| `CLAUDE_NOTIFY_SOUND` | `Glass` | macOS notification sound name (`Glass`, `Ping`, `Pop`, `Purr`, etc.) |
| `CLAUDE_NOTIFY_DEBUG` | — | Set to `1` to write debug logs to `/tmp/claude-notify.log` |

## Troubleshooting

### Test notification manually

```bash
echo '{"hook_event_name":"Stop"}' | bash ~/.claude/hooks/notify.sh
```

### Enable debug logging

```bash
echo '{"hook_event_name":"Stop"}' | CLAUDE_NOTIFY_DEBUG=1 bash ~/.claude/hooks/notify.sh
cat /tmp/claude-notify.log
```

### No notifications showing?

1. **Install `terminal-notifier`** — the built-in `osascript` notifications are often silently suppressed by macOS:
   ```bash
   brew install terminal-notifier
   ```

2. **Check notification permissions** — go to **System Settings > Notifications**, find your terminal app (or `terminal-notifier`), and ensure:
   - "Allow Notifications" is ON
   - Notification style is "Banners" or "Alerts" (not "None")

3. **Check Focus mode** — make sure Do Not Disturb / Focus mode is not blocking notifications.

### Notifications appear but no click-to-focus?

Click-to-focus requires `terminal-notifier`. It does not work with the `osascript` fallback.

## How It Works

This project uses [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — shell commands that Claude Code runs automatically on specific events. The hook script:

1. Receives event data as JSON via stdin from Claude Code
2. Parses the event type and details (using `python3` with `grep/sed` fallback)
3. Maps the event to a human-readable title and message
4. Sends a macOS notification via `terminal-notifier` (preferred) or `osascript`
5. On click, activates your terminal app so you can respond immediately

## Requirements

- macOS
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `python3` (pre-installed on macOS)
- `terminal-notifier` (recommended) — install via `brew install terminal-notifier`

## License

MIT
