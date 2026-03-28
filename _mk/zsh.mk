.PHONY: setup-zsh
setup-zsh:
	@echo "  -> zsh setup (placeholder)"

.PHONY: link
link: link-zshrc link-secrets ## シンボリックリンクを展開し、dotfiles を配置します

.PHONY: link-zshrc
link-zshrc:
	@echo "==> Linking zsh configuration files"
	mkdir -p "$(HOME)"
	ln -sfn "$(REPO_ROOT)/zshrc" "$(HOME)/.zshrc"
	ln -sfn "$(REPO_ROOT)/zsh_env" "$(HOME)/.zsh_env"

.PHONY: link-secrets
link-secrets:
	@echo "==> Linking/Copying zsh secrets"
	@if [ ! -f "$(HOME)/.zsh_secrets.example" ]; then \
		cp "$(REPO_ROOT)/zsh_secrets.example" "$(HOME)/.zsh_secrets.example" && \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi
	@if [ -f "$(HOME)/.zsh_secrets.example" ]; then \
		chmod 600 "$(HOME)/.zsh_secrets.example"; \
	fi
