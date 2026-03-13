SHELL = /bin/bash
.DEFAULT_GOAL: help

PACKAGES = zsh git tmux tool-versions nvim claude direnv ssh

help: ## Show all available commands
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup

install: ## Install dotfiles (first time setup)
	@command -v stow >/dev/null || (echo "Installing GNU Stow..." && brew install stow)
	@mkdir -p ~/.config/nvim ~/.config/direnv ~/.ssh/config.d ~/.secrets
	@for pkg in $(PACKAGES); do echo "Stowing $$pkg..."; stow -t ~ $$pkg; done
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

##@ Checks

check: ## Verify all symlinks are intact
	@ok=true; \
	for f in ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.tool-versions ~/.mcp.json ~/.config/nvim/init.lua ~/.config/direnv/direnv.toml ~/.ssh/config; do \
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
