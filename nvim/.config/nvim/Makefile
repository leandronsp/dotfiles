SHELL = /bin/bash
.ONESHELL:
.DEFAULT_GOAL: help

help: ## Show all available commands
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Essential Commands

sync: ## Sync all plugins and tools
	@nvim --headless -c "Lazy sync" -c "qall"
	@nvim --headless -c "MasonToolsUpdate" -c "qall" 2>/dev/null || true

test: ## Run test suite
	@nvim -l tests/run.lua

health: ## Run health checks
	@nvim --headless -c "checkhealth" -c "qall"

doctor: ## Full diagnostic check
	@make health && make test

##@ Plugin Management  

install: ## Install missing plugins
	@nvim --headless -c "Lazy install" -c "qall"

update: ## Update plugins to latest
	@nvim --headless -c "Lazy update" -c "qall"

clean: ## Remove unused plugins
	@nvim --headless -c "Lazy clean" -c "qall"

restore: ## Restore from lockfile
	@nvim --headless -c "Lazy restore" -c "qall"

##@ Development

format: ## Format Lua files (requires stylua)
	@if command -v stylua >/dev/null 2>&1; then \
		stylua lua/; \
		echo "✅ Lua files formatted"; \
	else \
		echo "❌ Install stylua: cargo install stylua"; \
	fi

lint: ## Check Lua code style
	@if command -v stylua >/dev/null 2>&1; then \
		stylua --check lua/; \
	else \
		echo "❌ Install stylua: cargo install stylua"; \
	fi

startup-time: ## Measure startup time
	@nvim --startuptime /tmp/nvim-startup.log -c "qall" && tail -1 /tmp/nvim-startup.log

dev: ## Start with debug logging
	@NVIM_LOG_LEVEL=DEBUG nvim

##@ Maintenance

backup: ## Create backup
	@cp -r ~/.config/nvim ~/.config/nvim-backup-$(shell date +%Y%m%d-%H%M%S)
	@echo "✅ Backup created"

clean-cache: ## Clear cache and state
	@rm -rf ~/.cache/nvim ~/.local/state/nvim
	@echo "✅ Cache cleared"

reset: ## Full reset (removes all data)
	@echo "⚠️  This removes ALL plugins and data"
	@read -p "Continue? [y/N]: " confirm && [ "$$confirm" = "y" ] && \
	rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim || echo "Cancelled"

info: ## Show config info
	@echo "📁 Config: ~/.config/nvim"
	@echo "📦 Data: $$(du -sh ~/.local/share/nvim 2>/dev/null || echo 'Not found')"
	@echo "🧪 Tests: $$(find lua/tests/ -name "*_spec.lua" | wc -l) files"
	@echo "🔌 Plugins: $$(find lua/plugins/ -name "*.lua" | wc -l) modules"