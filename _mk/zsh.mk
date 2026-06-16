TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
FORCE ?= 0
REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null || pwd)
ZSH_DIR := $(CURDIR)

# $(1): ソースファイル (絶対パス), $(2): ターゲットファイル (絶対パス)
define SAFE_LN
	@if [ "$(FORCE)" != "1" ] && [ -e "$(2)" ] && [ ! -L "$(2)" ]; then \
		mv "$(2)" "$(2).$(TIMESTAMP).bak"; \
		echo "  -> Backed up existing $(2) to $(2).$(TIMESTAMP).bak"; \
	fi
	ln -sfn "$(1)" "$(2)"
endef

.PHONY: setup-zsh
setup-zsh: ## Zsh の設定適用 (シンボリックリンク作成)
	@echo "==> Linking zsh configuration files"
	@mkdir -p "$(HOME)"
	$(call SAFE_LN,$(ZSH_DIR)/zshrc,$(HOME)/.zshrc)
	$(call SAFE_LN,$(ZSH_DIR)/zsh_env,$(HOME)/.zsh_env)
	$(call SAFE_LN,$(ZSH_DIR)/npmrc,$(HOME)/.npmrc)
	$(call SAFE_LN,$(ZSH_DIR)/prompts/p10.zsh,$(HOME)/.p10k.zsh)
	@$(MAKE) .setup-zsh-secrets-impl
	@$(MAKE) .setup-gh-auth

.PHONY: .setup-gh-auth
.setup-gh-auth:
	@if command -v gh >/dev/null 2>&1; then \
		echo "==> Checking GitHub CLI authentication status..."; \
		SCOPES=$$(gh auth status --show-token 2>&1 | grep "Token scopes" | tr -d "'"); \
		case "$$SCOPES" in \
			*read:packages*) echo "  ✅ GitHub CLI is authenticated with required scopes." ;; \
			*) \
				echo "  ⚠️  GitHub CLI is not authenticated or lacks 'read:packages' scope."; \
				echo "  Please run the following command to login:"; \
				echo "    unset GITHUB_TOKEN && gh auth login -s read:packages,write:packages,repo,workflow,gist,read:org"; \
				;; \
		esac; \
	else \
		echo "  ⚠️  GitHub CLI (gh) not found. Please install it for package access."; \
	fi

.PHONY: .setup-zsh-secrets-impl
.setup-zsh-secrets-impl:
	@if [ ! -f "$(ZSH_DIR)/.zsh_secrets" ]; then \
		cp "$(ZSH_DIR)/zsh_secrets.example" "$(ZSH_DIR)/.zsh_secrets"; \
		echo "  ✅ Created $(ZSH_DIR)/.zsh_secrets from example."; \
		UPDATE_ALL=y; \
	else \
		printf "⚠️  .zsh_secrets already exists. Update variables? (y/N) [n]: "; \
		read confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then UPDATE_ALL=y; else UPDATE_ALL=n; fi; \
	fi; \
	VARS=$$(grep -E '^export [A-Z0-9_]+=' "$(ZSH_DIR)/zsh_secrets.example" | sed -E 's/^export ([A-Z0-9_]+)=.*/\1/'); \
	for var in $$VARS; do \
		CURRENT_VAL=$$(grep -E "^export $$var=" "$(ZSH_DIR)/.zsh_secrets" | sed -E 's/^export [^=]+="?([^"]*)"?/\1/' | head -n 1); \
		EXAMPLE_VAL=$$(grep -E "^export $$var=" "$(ZSH_DIR)/zsh_secrets.example" | sed -E 's/^export [^=]+="?([^"]*)"?/\1/' | head -n 1); \
		if [ "$$UPDATE_ALL" = "y" ] || [ -z "$$CURRENT_VAL" ] || [ "$$CURRENT_VAL" = "$$EXAMPLE_VAL" ]; then \
			printf "🔑 $$var [$$CURRENT_VAL]: "; \
			read new_val; \
			new_val=$${new_val:-$$CURRENT_VAL}; \
			if grep -q "^export $$var=" "$(ZSH_DIR)/.zsh_secrets"; then \
				sed -i "s|^export $$var=.*|export $$var=\"$$new_val\"|" "$(ZSH_DIR)/.zsh_secrets"; \
			else \
				echo "export $$var=\"$$new_val\"" >> "$(ZSH_DIR)/.zsh_secrets"; \
			fi; \
		fi; \
	done

.PHONY: install-zsh
install-zsh: ## Zsh 関連のツールインストール
	@echo "==> Installing zsh dependencies"
	@if ! command -v zsh >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y zsh fzf; \
	else \
		echo "✅ zsh and fzf are already installed"; \
	fi
