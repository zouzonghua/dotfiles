# ai

Single source of truth for AI agent instructions. The per-tool entry files
(`gemini/.gemini/GEMINI.md`, `codex/.codex/AGENTS.md`, `claude/.claude/CLAUDE.md`)
are relative symlinks to `instructions.md` here.

To update behavior across all agents at once, edit `instructions.md` only.

This directory is **not** a stow module — it is the upstream source. The agent
modules are the ones stowed into `$HOME`.

## Codex skills

`karpathy-guidelines` and `code-simplifier` are installed directly into
`~/.codex/skills`, not managed by Stow.

Install `karpathy-guidelines`:

```sh
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo multica-ai/andrej-karpathy-skills \
  --path skills/karpathy-guidelines
```

Install `code-simplifier`:

```sh
mkdir -p ~/.codex/skills/code-simplifier
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/code-simplifier/agents/code-simplifier.md \
  -o ~/.codex/skills/code-simplifier/SKILL.md
```

Restart Codex or open a new thread after installing skills.
