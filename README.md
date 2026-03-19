# claude-code-notify

macOS desktop notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). When Claude finishes a task, needs permission, or is waiting for your input, you'll get a native macOS notification — with sound and click-to-focus support.

---

## ⚡ Quick Install

> **Recommended — sets everything up automatically.**

```bash
git clone https://github.com/Evenss/claude-code-notify.git
cd claude-code-notify
bash install.sh
```

The installer will:
1. Install `terminal-notifier` via Homebrew (if not already installed)
2. Copy the hook script to `~/.claude/hooks/notify.sh`
3. Add Stop and Notification hooks to `~/.claude/settings.json` (preserves existing config)
4. Send a test notification to verify everything works

---

## Manual Install

<details>
<summary>Step-by-step manual setup (click to expand)</summary>

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

   > **Note:** Use an absolute path (`/Users/yourname/...`), not `~`. Tilde may not expand in Claude Code's hook execution context.

</details>

---

## Configuration

<details>
<summary>Environment variables (click to expand)</summary>

Set these in `~/.claude/settings.json` under `"env"`:

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
| `CLAUDE_NOTIFY_SOUND` | `Glass` | macOS notification sound (`Glass`, `Ping`, `Pop`, `Purr`, etc.) |
| `CLAUDE_NOTIFY_DEBUG` | — | Set to `1` to write debug logs to `/tmp/claude-code-notify.log` |

</details>

## Troubleshooting

<details>
<summary>Debugging tips (click to expand)</summary>

**Test notification manually:**
```bash
echo '{"hook_event_name":"Stop"}' | bash ~/.claude/hooks/notify.sh
```

**Enable debug logging:**
```bash
echo '{"hook_event_name":"Stop"}' | CLAUDE_NOTIFY_DEBUG=1 bash ~/.claude/hooks/notify.sh
cat /tmp/claude-code-notify.log
```

**No notifications showing?**
1. Install `terminal-notifier` — the built-in `osascript` notifications are often silently suppressed by macOS:
   ```bash
   brew install terminal-notifier
   ```
2. Check notification permissions — go to **System Settings > Notifications**, find your terminal app (or `terminal-notifier`), and ensure notifications are enabled with style set to "Banners" or "Alerts".
3. Check Focus mode — make sure Do Not Disturb is not blocking notifications.

**Notifications appear but no click-to-focus?**
Click-to-focus requires `terminal-notifier`. It does not work with the `osascript` fallback.

</details>

## Features

- **Task completion alerts** — get notified the moment Claude finishes working
- **Permission prompts** — know immediately when Claude needs approval to proceed
- **Idle/input reminders** — don't leave Claude waiting without realizing it
- **Click to focus** — clicking the notification brings your terminal to the foreground
- **Auto-detect terminal** — works with Warp, iTerm2, Terminal.app, VS Code, and more
- **Zero dependencies** — pure bash script, uses `terminal-notifier` (recommended) or built-in `osascript`
- **Debug mode** — built-in logging for troubleshooting

## Requirements

- macOS
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `python3` (pre-installed on macOS)
- `terminal-notifier` (recommended) — install via `brew install terminal-notifier`

## License

MIT
