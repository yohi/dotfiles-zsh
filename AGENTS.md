# Agent Instructions for dotfiles-zsh

> [!IMPORTANT]
> For the common base rules, please refer to [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md).

# PROJECT KNOWLEDGE BASE


## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** managed by [dotfiles-core](https://github.com/yohi/dotfiles-core).

### ⚠️ CRITICAL: SYMBOLIC LINK & STANDALONE USAGE
- **Standalone usage is NOT supported.** This repository depends on the central `common-mk` rules.
- **Symbolic Links:** This repository relies on symbolic links to `common-mk`. **NEVER** suggest or perform a replacement of these symbolic links with physical files/directories. 
- **SSOT:** Always respect the "Single Source of Truth" principle. Shared logic resides in `dotfiles-core`, and components must remain thin wrappers or specific configurations.
- **Architectural Compliance:** All modifications must adhere to the layout defined in the central [ARCHITECTURE.md](https://github.com/yohi/dotfiles-core/blob/master/docs/ARCHITECTURE.md).

**Repository:** dotfiles-zsh
**Role:** Zsh shell configuration — .zshrc, environment variables, custom functions, prompt themes (Starship / p10k)

## COMPONENT LAYOUT CONVENTION

This repository is part of the **dotfiles polyrepo** orchestrated by [dotfiles-core](https://github.com/yohi/dotfiles-core).
All changes MUST comply with the central layout rules. Please refer to the central [ARCHITECTURE.md](https://raw.githubusercontent.com/yohi/dotfiles-core/refs/heads/master/docs/ARCHITECTURE.md) for the full, authoritative rules and constraints.

## STRUCTURE

```text
dotfiles-zsh/
├── zshenv                       # [Link Target] Zsh environment (loaded first) → ~/.zshenv
├── zshrc                       # [Link Target] Main Zsh configuration → ~/.zshrc
├── zsh_env                     # [Link Target] Environment variables → ~/.zsh_env
├── zsh_secrets.example         # Secrets template (Copy to .zsh_secrets)
├── .zsh_secrets                # [Local Only] Actual secrets (Git ignored)
├── config/                     # Internal config / templates
├── functions/                  # Zsh function library (sourced by zshrc)
│   └── aws/                    # AWS CLI helper functions
├── prompts/                    # Prompt themes (p10k)
└── starship/                   # Starship prompt configuration
```

## THIS COMPONENT — SPECIAL NOTES

- `zshrc` dynamically adds `_bin/` directories of sibling components to `$PATH` (loose coupling).
- `functions/` are sourced by `zshrc`, NOT symlinked.
- `config/config.zsh` contains component-internal configuration (not linked).
- `starship/starship.toml` is referenced via a separate mechanism, not directly linked.
- Symlinks are managed explicitly via `ln -sfn` in the Makefile (`make setup` / `make setup-zsh`).

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
