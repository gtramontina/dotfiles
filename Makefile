HOST := $(shell hostname -s)
SYSTEM := $(shell uname -s)
USER := $(shell whoami)

.PHONY: switch build update help

switch: ## Apply configuration
ifeq ($(SYSTEM),Darwin)
	darwin-rebuild switch --flake .#$(HOST)
else
	home-manager switch --flake .#$(USER)@$(HOST)
endif

build: ## Build without applying
ifeq ($(SYSTEM),Darwin)
	darwin-rebuild build --flake .#$(HOST)
else
	home-manager build --flake .#$(USER)@$(HOST)
endif

update: ## Update flake inputs and apply
	nix flake update
	$(MAKE) switch

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'
