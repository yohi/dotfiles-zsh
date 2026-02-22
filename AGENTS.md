# PROJECT KNOWLEDGE BASE

**Repository:** dotfiles-zsh
**Role:** Zsh shell configuration — .zshrc, environment variables, custom functions, prompt themes (Starship / p10k)

## STRUCTURE

```text
dotfiles-zsh/
├── .zshrc                      # [Stow → ~/] Main Zsh configuration
├── .zsh_env                    # [Stow → ~/] Environment variables
├── .zsh_secrets.example        # [Stow → ~/] Secrets template
├── config/                     # Internal config / templates
├── functions/                  # Zsh function library (sourced by .zshrc)
│   └── aws/                    # AWS CLI helper functions
├── prompts/                    # Prompt themes (p10k)
└── starship/                   # Starship prompt configuration
```

## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** orchestrated by `dotfiles-core`.
All changes MUST comply with the central layout rules. Please refer to [`dotfiles-core/docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md) for the full, authoritative rules and constraints.

## THIS COMPONENT — SPECIAL NOTES

- `.zshrc` dynamically adds `bin/` directories of sibling components to `$PATH` (loose coupling).
- `functions/` are sourced by `.zshrc`, NOT symlinked by Stow.
- `config/config.zsh` contains component-internal configuration (not Stow-linked).
- `starship/starship.toml` is referenced via a separate mechanism, not directly Stow-linked.

## CODE STYLE

- **Documentation / README**: Japanese (日本語)
- **AGENTS.md**: English
- **Commit Messages**: Japanese, Conventional Commits (e.g., `feat: 新機能追加`, `fix: バグ修正`)
- **Shell**: `set -euo pipefail`, dynamic path resolution, idempotent operations

## FORBIDDEN OPERATIONS

Per `opencode.jsonc` (when present), these operations are blocked for agent execution:

- `rm` (destructive file operations)
- `ssh` (remote access)
- `sudo` (privilege escalation)
