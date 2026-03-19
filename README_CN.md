# claude-code-notify

[English](README.md)

为 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 提供 macOS 桌面通知功能。当 Claude 完成任务、需要授权或等待你的输入时，你将收到原生 macOS 通知——支持声音提示和点击聚焦。

---

## ⚡ 快速安装

> **推荐方式——自动完成所有配置。**

```bash
git clone https://github.com/Evenss/claude-code-notify.git
cd claude-code-notify
bash install.sh
```

安装脚本将自动完成以下步骤：
1. 通过 Homebrew 安装 `terminal-notifier`（如果尚未安装）
2. 将 hook 脚本复制到 `~/.claude/hooks/notify.sh`
3. 将 Stop 和 Notification 钩子添加到 `~/.claude/settings.json`（保留现有配置）
4. 发送测试通知以验证一切正常

---

## 手动安装

<details>
<summary>逐步手动配置（点击展开）</summary>

1. 安装 terminal-notifier（推荐，以获得可靠的通知和点击聚焦功能）：
   ```bash
   brew install terminal-notifier
   ```

2. 复制 hook 脚本：
   ```bash
   mkdir -p ~/.claude/hooks
   cp notify.sh ~/.claude/hooks/notify.sh
   chmod +x ~/.claude/hooks/notify.sh
   ```

3. 将钩子添加到 `~/.claude/settings.json`：
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

   > **注意：** 请使用绝对路径（`/Users/yourname/...`），而非 `~`。在 Claude Code 的 hook 执行环境中，波浪符可能无法正确展开。

</details>

---

## 配置

<details>
<summary>环境变量（点击展开）</summary>

在 `~/.claude/settings.json` 的 `"env"` 字段中进行设置：

```json
{
  "env": {
    "CLAUDE_NOTIFY_SOUND": "Ping"
  }
}
```

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `CLAUDE_NOTIFY_DISABLED` | — | 设置为 `1` 以禁用所有通知 |
| `CLAUDE_NOTIFY_SOUND` | `Glass` | macOS 通知声音（`Glass`、`Ping`、`Pop`、`Purr` 等） |
| `CLAUDE_NOTIFY_DEBUG` | — | 设置为 `1` 以将调试日志写入 `/tmp/claude-code-notify.log` |

</details>

## 故障排查

<details>
<summary>调试技巧（点击展开）</summary>

**手动测试通知：**
```bash
echo '{"hook_event_name":"Stop"}' | bash ~/.claude/hooks/notify.sh
```

**启用调试日志：**
```bash
echo '{"hook_event_name":"Stop"}' | CLAUDE_NOTIFY_DEBUG=1 bash ~/.claude/hooks/notify.sh
cat /tmp/claude-code-notify.log
```

**通知不显示？**
1. 安装 `terminal-notifier`——macOS 系统内置的 `osascript` 通知经常被静默屏蔽：
   ```bash
   brew install terminal-notifier
   ```
2. 检查通知权限——前往**系统设置 > 通知**，找到你的终端应用（或 `terminal-notifier`），确保通知已启用且样式设置为"横幅"或"提醒"。
3. 检查专注模式——确保勿扰模式未拦截通知。

**通知出现但点击无法聚焦？**
点击聚焦功能需要 `terminal-notifier`，使用 `osascript` 回退方案时不支持此功能。

</details>

## 功能特性

- **任务完成提醒** — Claude 完成工作的第一时间收到通知
- **权限请求提醒** — 立即知晓 Claude 需要审批才能继续
- **等待输入提醒** — 不再让 Claude 在你不知情的情况下空等
- **点击聚焦** — 点击通知即可将终端窗口带到前台
- **自动识别终端** — 支持 Warp、iTerm2、Terminal.app、VS Code 等
- **零额外依赖** — 纯 bash 脚本，使用 `terminal-notifier`（推荐）或内置 `osascript`
- **调试模式** — 内置日志功能，方便排查问题

## 环境要求

- macOS
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `python3`（macOS 预装）
- `terminal-notifier`（推荐）— 通过 `brew install terminal-notifier` 安装

## 许可证

MIT
