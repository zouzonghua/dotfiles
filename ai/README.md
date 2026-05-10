# ai

Single source of truth for AI agent instructions. The per-tool entry files
(`gemini/.gemini/GEMINI.md`, `codex/.codex/AGENTS.md`, `claude/.claude/CLAUDE.md`)
are relative symlinks to `instructions.md` here.

To update behavior across all agents at once, edit `instructions.md` only.

This directory is **not** a stow module — it is the upstream source. The agent
modules are the ones stowed into `$HOME`.
