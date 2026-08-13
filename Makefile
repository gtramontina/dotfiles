HOST := $(shell hostname -s)
SYSTEM := $(shell uname -s)
USER := $(shell whoami)
IDENTITY_ARGS := $(if $(wildcard identity.override/default.nix),--override-input identity path:./identity.override)

.PHONY: switch build update fmt check test help

switch: ## Apply configuration
ifeq ($(SYSTEM),Darwin)
	nix run $(IDENTITY_ARGS) .#darwin-rebuild -- switch --flake .#$(HOST) $(IDENTITY_ARGS)
else
	nix run $(IDENTITY_ARGS) .#home-manager -- switch --flake .#$(USER)@$(HOST) $(IDENTITY_ARGS)
endif

build: ## Build without applying
ifeq ($(SYSTEM),Darwin)
	nix run $(IDENTITY_ARGS) .#darwin-rebuild -- build --flake .#$(HOST) $(IDENTITY_ARGS)
else
	nix run $(IDENTITY_ARGS) .#home-manager -- build --flake .#$(USER)@$(HOST) $(IDENTITY_ARGS)
endif

update: ## Update flake inputs and apply
	nix flake update
	$(MAKE) switch

fmt: ## Format all nix and shell files
	nix fmt

check: ## Run all checks (actionlint + treefmt + shellcheck)
	nix flake check $(IDENTITY_ARGS)

test: check ## Run checks and behavior tests
	nix develop $(IDENTITY_ARGS) -c bats tests

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'
