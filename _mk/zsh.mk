TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
FORCE ?= 0

# $(1): ソースファイル (REPO_ROOT 相対), $(2): ターゲットファイル (絶対パス)
define SAFE_LN
	@if [ "$(FORCE)" != "1" ] && [ -e "$(2)" ] && [ ! -L "$(2)" ]; then \
		mv "$(2)" "$(2).$(TIMESTAMP).bak"; \
		echo "  -> Backed up existing $(2) to $(2).$(TIMESTAMP).bak"; \
	fi
	ln -sfn "$(1)" "$(2)"
endef

.PHONY: setup-zsh
setup-zsh:
	@echo "  -> zsh setup (placeholder)"

.PHONY: link
link: link-zshrc link-secrets ## シンボリックリンクを展開し、dotfiles を配置します

.PHONY: link-zshrc
link-zshrc:
	@echo "==> Linking zsh configuration files"
	@mkdir -p "$(HOME)"
	$(call SAFE_LN,$(REPO_ROOT)/zshrc,$(HOME)/.zshrc)
	$(call SAFE_LN,$(REPO_ROOT)/zsh_env,$(HOME)/.zsh_env)

.PHONY: link-secrets
link-secrets:
	@echo "==> Linking/Copying zsh secrets"
	@mkdir -p "$(HOME)"
	@if [ ! -f "$(HOME)/.zsh_secrets.example" ]; then \
		cp "$(REPO_ROOT)/zsh_secrets.example" "$(HOME)/.zsh_secrets.example" && \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi
