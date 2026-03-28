# Design Document: Fix and Verify Findings (2026-03-28)

## Overview
This document outlines the fixes for three findings in the `dotfiles-zsh` repository to ensure language consistency, fail-fast behavior in the Makefile, and correct standalone setup instructions.

## Proposed Changes

### 1. `AGENTS.md` (Update Language)
- **Problem**: The `[!IMPORTANT]` block at line 4 is in Japanese, while the document's language policy is English.
- **Fix**: Update the Japanese notice to an English sentence.
- **Original**: `> 共通の基本ルールは [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md) を参照してください。`
- **Target**: `> For the common base rules, please refer to [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md).`

### 2. `Makefile` (Mandatory Includes)
- **Problem**: Core Makefile fragments are optionally included (`-include`), which can hide setup issues.
- **Fix**: Change `-include` to mandatory `include` for `_mk/core.mk` and `_mk/help.mk`.
- **Target**: 
  ```makefile
  include _mk/core.mk
  include _mk/help.mk
  ```

### 3. `README.md` (Standalone Path Consistency)
- **Problem**: The instruction for standalone setup says to place `common-mk` at `../common-mk/`, but existing symlinks point to `../../common-mk/` (relative to root).
- **Fix**: Update the path in the instructions to `../../common-mk/` to ensure symlinks resolve correctly.
- **Target**:
  ```markdown
  2. Place it such that it's available at `../../common-mk/` relative to this repository root.
  ```

## Verification Strategy
1.  **Code Review**: Verify that the changes match the targets.
2.  **Makefile Validation**:
    - Ensure `make` runs correctly when `../../common-mk/` exists.
    - (Optional) Verify it fails when `../../common-mk/` is missing (if safe to test).
3.  **Documentation Check**: Verify the phrasing in `AGENTS.md` and `README.md`.
