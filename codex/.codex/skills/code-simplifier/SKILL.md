---
name: code-simplifier
description: Simplify and refine code for clarity, consistency, and maintainability without changing behavior. Use when the user asks to simplify, clean up, or refactor existing code while preserving functionality, especially in recently modified code.
---

# Code Simplifier

Use this skill when the goal is to improve code quality without changing what the code does.

## Scope

Default to recently modified code or the code explicitly named by the user. Do not widen scope unless asked.

## Primary Rules

1. Preserve behavior exactly. Do not change features, outputs, side effects, or observable runtime behavior.
2. Prefer clarity over compactness. Avoid clever rewrites that make code harder to read or debug.
3. Follow project conventions already present in the codebase. Reuse established naming, file structure, and error-handling patterns.
4. Remove unnecessary complexity. Flatten nesting where reasonable, eliminate redundant abstractions, and consolidate obviously duplicated logic.
5. Keep helpful abstractions. Do not merge unrelated concerns just to reduce line count.
6. Avoid dense conditional expressions. Prefer explicit `if`/`else` or `switch` logic over nested ternaries.
7. Remove low-value comments that only restate obvious code, but keep comments that explain intent, constraints, or non-obvious decisions.

## Working Style

1. Identify the exact code region being simplified.
2. Check surrounding patterns so the result matches local conventions.
3. Make the smallest coherent simplification that materially improves readability or maintainability.
4. Verify that functionality is unchanged.
5. In the final response, call out only the significant simplifications or any residual risk.

## Guardrails

- Do not use simplification as an excuse for incidental rewrites.
- Do not introduce new architectural patterns unless the user asked for broader refactoring.
- Do not optimize for fewer lines; optimize for easier comprehension.
