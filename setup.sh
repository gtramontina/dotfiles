#!/bin/bash

set -eo pipefail

function main() {
	[[ "$OSTYPE" == "darwin"* ]] || die "This setup only runs on darwin."

	local host="$1"
	[[ -n "$host" ]] || die "$(usage)"
	[[ -f "host/$host.nix" ]] || die "Host '$host' not found."

	log::info "Setting up Nix environment…"

	sudo scutil --set HostName "$host"
	sudo scutil --set LocalHostName "$host"
	sudo scutil --set ComputerName "$host"

	if [[ -z "$(command -v git)" ]]; then
		log::info "Installing git via xcode-select…"
		xcode-select --install
	fi

	if [[ -z "$(command -v brew)" ]]; then
		log::info "Installing homebrew…"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	if [[ -z "$(command -v nix)" ]]; then
		log::info "Installing Nix…"
		/bin/sh -c "$(curl -fsSL https://nixos.org/nix/install)" --darwin-use-unencrypted-nix-store-volume --daemon

		log::warn "PLEASE FOLLOW THE INSTRUCTIONS ABOVE!"
		log::warn "Re-run this script once your done."
		exit 0
	fi

	if ! nix-channel --list | grep -q 'home-manager'; then
		log::info "Adding 'home-manager' channel…"
		nix-channel --add "https://github.com/nix-community/home-manager/archive/master.tar.gz" home-manager

		log::info "Updating all channels…"
		nix-channel --update
	fi

	if [[ ! -f "$(pwd)/result/bin/darwin-installer" ]]; then
		log::info "Installing nix-darwin…"

		if [[ ! "$HOME/.config/nixpkgs" -ef "$(pwd)/host" ]]; then
			rm -rf "$HOME/.config/nixpkgs"
			(mkdir -p "$HOME/.config" || true) && ln -s "$(pwd)/host" "$HOME/.config/nixpkgs"
		fi

		if [[ ! "$(readlink "$HOME/.nixpkgs/darwin-configuration.nix")" -ef "$(pwd)/host/$host.nix" ]]; then
			rm -rf "$HOME/.nixpkgs/darwin-configuration.nix"
			(mkdir -p "$HOME/.nixpkgs" || true) && ln -s "$(pwd)/host/$host.nix" "$HOME/.nixpkgs/darwin-configuration.nix"
		fi

		nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
	fi

	yes n | ./result/bin/darwin-installer
}

# ---

function usage() {
	echo -e "\n\n Usage: $(basename "$0") <host>"
	echo -e "\n Available hosts:"
	find host -depth 1 -name '*.nix' -exec basename {} .nix \; | sed -e 's/^/  • /'
}

function color::reset() { echo -e "$1\033[0m"; }
function color::red() { echo -e "\033[0;31m$(color::reset "$1")"; }
function color::yellow() { echo -e "\033[0;33m$(color::reset "$1")"; }
function color::blue() { echo -e "\033[0;34m$(color::reset "$1")"; }
function log::log() { echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $1"; }
function log::error() { log::log "$(color::red "$1")" >&2; }
function log::warn() { log::log "$(color::yellow "$1")" >&2; }
function log::info() { log::log "$(color::blue "$1")"; }
function die() { log::error "$1" && exit "${2:-1}"; }

# ---

main "$@"
