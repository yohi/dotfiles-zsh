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
	@if [ ! -f "$(HOME)/.zsh_secrets" ]; then \
		cp "$(ZSH_DIR)/zsh_secrets.example" "$(HOME)/.zsh_secrets" && \
		echo "  -> Created $(HOME)/.zsh_secrets from example"; \
	fi

.PHONY: install-zsh
install-zsh: ## Zsh 関連のツールインストール
	@echo "==> Installing zsh dependencies"
	sudo apt-get update && sudo apt-get install -y zsh fzf
