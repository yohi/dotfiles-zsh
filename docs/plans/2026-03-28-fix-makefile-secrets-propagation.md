# Fix Makefile Secrets Command Failure Propagation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `Makefile` の `link-secrets` ターゲットにおいて、`cp` コマンドの失敗が `make` に正しく伝播するように修正します。

**Architecture:** セミコロン（`;`）を `&&` に置き換え、シェルの終了ステータスを保持します。

**Tech Stack:** Makefile, POSIX Shell

---

### Task 1: Verify the issue with a failing scenario

**Files:**
- Modify: `Makefile:28-31` (Temporarily for testing)

**Step 1: Create a failing test case (Manual Verification)**
コピー元ファイルが存在しない、またはコピー先ディレクトリが読み取り専用であるなどの状況で `make link-secrets` を実行し、現状では `Success` と表示され終了ステータスが `0` になることを確認します。

Run: `make link-secrets REPO_ROOT=/tmp/non-existent-dir`
Expected: `cp: ...: No such file or directory` とエラーが出るが、その後に `Copied...` と表示され、`echo $?` が `0` を返す。

---

### Task 2: Implement the fix

**Files:**
- Modify: `Makefile:28-31`

**Step 1: Replace semicolon with &&**

```makefile
	@if [ ! -f "$(HOME)/.zsh_secrets.example" ]; then \
		cp "$(REPO_ROOT)/zsh_secrets.example" "$(HOME)/.zsh_secrets.example" && \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi
```

**Step 2: Run the same failing test case**

Run: `make link-secrets REPO_ROOT=/tmp/non-existent-dir`
Expected: `cp: ...: No such file or directory` と表示され、`Copied...` は表示されず、`echo $?` が `1`（非ゼロ）を返す。

**Step 3: Verify the successful case**

Run: `rm -f $(HOME)/.zsh_secrets.example && make link-secrets`
Expected: `Copied zsh_secrets.example to /home/y_ohi/.zsh_secrets.example` と表示され、`echo $?` が `0` を返す。

---

### Task 3: Finalize and Commit

**Step 1: Commit the changes**

Run: `git add Makefile && git commit -m "fix(make): propagate cp failure in link-secrets"`

**Step 2: Remove the design document and plan (Optional, following project rules)**
通常は残しますが、指示があれば削除します。
