# agents

Single source of truth for shared AI agent instructions. The per-tool entry files
(`gemini/.gemini/GEMINI.md`, `codex/.codex/AGENTS.md`,
`pi/.pi/agent/AGENTS.md`) are relative symlinks to `AGENTS.md` here.

To update behavior across all agents at once, edit `AGENTS.md` only.

This directory is **not** a stow module — it is the upstream source. The agent
modules are the ones stowed into `$HOME`.

## Codex skills

`karpathy-guidelines` is installed directly into `~/.codex/skills`, not managed
by Stow.

Install `karpathy-guidelines`:

```sh
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo multica-ai/andrej-karpathy-skills \
  --path skills/karpathy-guidelines
```

Restart Codex or open a new thread after installing skills.
