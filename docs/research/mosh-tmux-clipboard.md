# Mosh + tmux 系统剪贴板研究

## 结论

Mosh 1.4.0 支持 OSC 52，但其解析器只接受明确使用 `c` 选择器的 `OSC 52;c;...`。tmux 的原生 `set-clipboard` / `load-buffer -w` 在 Mosh 1.4.0 中仍有公开未解决案例。可靠的社区方案是让 tmux `copy-pipe` 调用脚本，脚本生成明确的 `OSC 52;c;...`，再通过 tmux DCS passthrough 发送到 Mosh。

## 依据

- Mosh 1.4.0 发布说明宣布支持 OSC 52：https://github.com/mobile-shell/mosh/releases/tag/mosh-1.4.0
- Mosh 1.4.0 源码仅匹配 `52;c;`：https://github.com/mobile-shell/mosh/blob/mosh-1.4.0/src/terminal/terminalfunctions.cc
- Mosh #1311 使用 Mosh 1.4.0 + tmux 复现 `load-buffer -w` 失败；`terminal-overrides` 无效，而显式 yank 脚本有效：https://github.com/mobile-shell/mosh/issues/1311
- tmux #3423 记录“单独 Mosh、单独 tmux 均正常，组合后失败”，并指向 Mosh 处理方式：https://github.com/tmux/tmux/issues/3423
- tmux 官方 Clipboard Wiki 说明 `set-clipboard`、`Ms`、`copy-pipe` 与嵌套 tmux 条件：https://github.com/tmux/tmux/wiki/Clipboard
- 社区验证的 DCS passthrough yank 方案：https://sunaku.github.io/tmux-yank-osc52.html

## 采用方案

```tmux
set-option -g allow-passthrough on
bind -T copy-mode-vi y send-keys -X copy-pipe "~/.config/tmux/bin/osc52-copy.sh > '#{pane_tty}'"
```

脚本输出：

```text
DCS tmux passthrough (OSC 52;c;<base64>)
```

`copy-pipe` 同时保留 tmux buffer，因此不会牺牲 tmux 内部复制粘贴。
