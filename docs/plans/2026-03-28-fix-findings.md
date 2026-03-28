# Fix and Verify Findings Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal**: Update `AGENTS.md`, `Makefile`, and `README.md` to fix language, include, and path issues.

**Architecture**: Direct file modifications using `replace` tool, followed by verification using `make`.

**Tech Stack**: Markdown, Makefile, Shell.

---

### Task 1: Update `AGENTS.md` Language

**Files**:
- Modify: `AGENTS.md:4`

**Step 1: Replace Japanese text with English**
Old: `> 共通の基本ルールは [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md) を参照してください。`
New: `> For the common base rules, please refer to [DOTFILES_COMMON_RULES.md](./DOTFILES_COMMON_RULES.md).`

**Step 2: Verify change**
Run: `grep "common base rules" AGENTS.md`
Expected: Line 4 matches the new text.

**Step 3: Commit**
Run: `git add AGENTS.md && git commit -m "docs(zsh): update Japanese notice to English in AGENTS.md"`

---

### Task 2: Make `Makefile` Includes Mandatory

**Files**:
- Modify: `Makefile:3-4`

**Step 1: Replace `-include` with `include`**
Old:
```makefile
-include _mk/core.mk
-include _mk/help.mk
```
New:
```makefile
include _mk/core.mk
include _mk/help.mk
```

**Step 2: Verify change**
Run: `grep "^include _mk/" Makefile`
Expected: Two lines starting with `include _mk/`.

**Step 3: Verify Makefile execution**
Run: `make help`
Expected: Success (since `../../common-mk/` exists in this environment).

**Step 4: Commit**
Run: `git add Makefile && git commit -m "build(zsh): make core Makefile fragments mandatory"`

---

### Task 3: Update `README.md` Standalone Path

**Files**:
- Modify: `README.md:52`

**Step 1: Replace `../common-mk/` with `../../common-mk/`**
Old: `2. Place it such that it's available at \`../common-mk/\` relative to this repository root.`
New: `2. Place it such that it's available at \`../../common-mk/\` relative to this repository root.`

**Step 2: Verify change**
Run: `grep "../../common-mk/" README.md`
Expected: Line 52 matches the new path.

**Step 3: Commit**
Run: `git add README.md && git commit -m "docs(zsh): correct standalone setup path in README.md"`

---

### Task 4: Final Verification

**Step 1: Run `make` to ensure everything is still working**
Run: `make help`
Expected: Display help message without errors.

**Step 2: Use \`verification-before-completion\` skill**
Invoke: \`activate_skill(verification-before-completion)\` and follow instructions.
