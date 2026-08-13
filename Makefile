HOST := $(shell hostname -s)
SYSTEM := $(shell uname -s)
USER := $(shell whoami)
NIX := $(shell command -v nix)
NIX_COLLECT_GARBAGE := $(dir $(NIX))nix-collect-garbage
DETERMINATE_NIXD := $(shell command -v determinate-nixd)
IDENTITY_ARGS := $(if $(wildcard identity.override/default.nix),--override-input identity path:./identity.override)

.PHONY: switch build update nix-upgrade clean fmt check test help

switch: ## Apply configuration
ifeq ($(SYSTEM),Darwin)
	sudo --set-home $(NIX) run $(IDENTITY_ARGS) .#darwin-rebuild -- switch --flake .#$(HOST) $(IDENTITY_ARGS)
else
	nix run $(IDENTITY_ARGS) .#home-manager -- switch --flake .#$(USER)@$(HOST) $(IDENTITY_ARGS)
endif

build: ## Build without applying
ifeq ($(SYSTEM),Darwin)
	nix run $(IDENTITY_ARGS) .#darwin-rebuild -- build --flake .#$(HOST) $(IDENTITY_ARGS)
else
	nix run $(IDENTITY_ARGS) .#home-manager -- build --flake .#$(USER)@$(HOST) $(IDENTITY_ARGS)
endif

update: ## Update, test, and build flake inputs
	$(NIX) flake update
	$(MAKE) test
	$(MAKE) build

nix-upgrade: ## Upgrade Determinate Nix
	@test -n "$(DETERMINATE_NIXD)" || { echo "Determinate Nix is not installed."; exit 1; }
	sudo --set-home $(DETERMINATE_NIXD) upgrade

clean: ## Delete Nix generations older than 30 days
	$(NIX_COLLECT_GARBAGE) --delete-older-than 30d
ifeq ($(SYSTEM),Darwin)
	sudo --set-home $(NIX_COLLECT_GARBAGE) --delete-older-than 30d
endif

fmt: ## Format all nix and shell files
	nix fmt

check: ## Run all checks (actionlint + treefmt + shellcheck)
	nix flake check $(IDENTITY_ARGS)

test: check ## Run checks and behavior tests
	nix develop $(IDENTITY_ARGS) -c bats tests

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'
