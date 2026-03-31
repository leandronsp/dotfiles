SHELL = /bin/bash
.DEFAULT_GOAL: help

PACKAGES = zsh git tmux tool-versions nvim claude direnv ssh local-bin ghostty

help: ## Show all available commands
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup

install: ## Install dotfiles (first time setup)
	@command -v stow >/dev/null || (echo "Installing GNU Stow..." && brew install stow)
	@mkdir -p ~/.config/nvim ~/.config/direnv ~/.config/ghostty ~/.ssh/config.d ~/.secrets
	@for pkg in $(PACKAGES); do echo "Stowing $$pkg..."; stow -t ~ $$pkg; done
	@$(MAKE) sync-claude
	@echo "Done. Run 'source ~/.zshrc' to reload."

uninstall: ## Remove all symlinks
	@for pkg in $(PACKAGES); do echo "Unstowing $$pkg..."; stow -D -t ~ $$pkg; done
	@echo "All symlinks removed."

restow: ## Re-stow all packages (fix conflicts)
	@for pkg in $(PACKAGES); do stow -R -t ~ $$pkg; done
	@echo "All packages re-stowed."

##@ Operations

stow-%: ## Stow a single package (e.g. make stow-zsh)
	@stow -t ~ $*

unstow-%: ## Unstow a single package (e.g. make unstow-zsh)
	@stow -D -t ~ $*

status: ## Show symlink status
	@for pkg in $(PACKAGES); do \
		conflicts=$$(stow -n -t ~ $$pkg 2>&1 | grep -v "^WARNING" | grep -v "^$$"); \
		if [ -z "$$conflicts" ]; then \
			printf "  \e[32mOK\e[0m    %s\n" "$$pkg"; \
		else \
			printf "  \e[31mDIRTY\e[0m %s\n" "$$pkg"; \
			echo "$$conflicts" | sed 's/^/        /'; \
		fi; \
	done

sync-claude: ## Sync portable settings into ~/.claude/settings.json
	@local=~/.claude/settings.local.json; \
	settings=~/.claude/settings.json; \
	if [ ! -f "$$local" ]; then echo "No settings.local.json found."; exit 1; fi; \
	if [ ! -f "$$settings" ]; then echo "No settings.json found."; exit 1; fi; \
	jq -n 'input as $$s | input | del(.permissions) | . as $$p | $$s | . + $$p' "$$settings" "$$local" > "$$settings.tmp" \
		&& mv "$$settings.tmp" "$$settings" \
		&& echo "Claude settings synced."

##@ Checks

deps: ## Check required dependencies
	@ok=true; \
	for cmd in brew stow git nvim tmux asdf mise direnv opam jq curl cargo claude elan pipx rg gcc unzip node stylua reattach-to-user-namespace qmd fswatch; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			printf "  \e[32mOK\e[0m    %s (%s)\n" "$$cmd" "$$(command -v $$cmd)"; \
		else \
			printf "  \e[31mMISS\e[0m  %s\n" "$$cmd"; ok=false; \
		fi; \
	done; \
	printf "\n"; \
	brew list gd >/dev/null 2>&1 \
		&& printf "  \e[32mOK\e[0m    %s\n" "brew:gd" \
		|| (printf "  \e[31mMISS\e[0m  %s\n" "brew:gd"; ok=false); \
	for dir in ~/.oh-my-zsh ~/.cargo ~/.secrets ~/vault; do \
		if [ -d "$$dir" ]; then \
			printf "  \e[32mOK\e[0m    %s\n" "$$dir"; \
		else \
			printf "  \e[31mMISS\e[0m  %s\n" "$$dir"; ok=false; \
		fi; \
	done; \
	$$ok && echo "All dependencies found." || echo "Some dependencies are missing."

check: ## Verify all symlinks are intact
	@ok=true; \
	for f in ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.tool-versions ~/.mcp.json ~/.config/nvim/init.lua ~/.config/direnv/direnv.toml ~/.ssh/config ~/.local/bin/abuf-edit ~/.config/ghostty; do \
		if [ -L "$$f" ]; then \
			printf "  \e[32mOK\e[0m    %s -> %s\n" "$$f" "$$(readlink $$f)"; \
		else \
			printf "  \e[31mMISS\e[0m  %s\n" "$$f"; ok=false; \
		fi; \
	done; \
	$$ok || (echo "Some symlinks are missing." && false)

lint: ## Check for hardcoded paths
	@echo "Checking for hardcoded /Users/ paths..."
	@grep -rn "/Users/" . --include='*' \
		--exclude-dir=.git \
		--exclude=Makefile \
		| grep -v '.gitconfig:.*email' \
		| grep -v 'github.com' \
		&& (printf "\e[31mFound hardcoded paths!\e[0m\n" && false) || echo "Clean."
