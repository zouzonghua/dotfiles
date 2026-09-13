# agents

Single source of truth for shared AI instructions and skills.

## Shared instructions

The per-tool entry files are relative symlinks to `agents/AGENTS.md`:

- `gemini/.gemini/GEMINI.md`
- `codex/.codex/AGENTS.md`
- `pi/.pi/agent/AGENTS.md`

## Shared skills

The Gemini, Codex, and Pi skill entries are relative symlinks to:

```text
agents/skills/karpathy-guidelines/SKILL.md
```

Edit files under `agents/` only. The tool-specific modules are deployed with GNU Stow.
