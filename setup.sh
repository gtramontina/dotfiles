#!/bin/bash

set -eo pipefail

function main() {
	[[ "$OSTYPE" == "darwin"* ]] || die "☠️ This setup only runs on darwin."

	if ! command -v nix &>/dev/null; then
		log::info "Installing Nix…"
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
		# local installer=$(mktemp).pkg
		# curl -fSLo "$installer" "https://install.determinate.systems/determinate-pkg/stable/Universal"
		# sudo installer -pkg "$installer" -target /
		# rm -f "$installer"
		log::info "Nix installed successfully."
		log::warn "⚠️ Start a new shell and run this script again!"
		# . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		return 0
	fi

	nix run . -- build --flake .
}

# ---

function color::reset() { echo -e "$1\033[0m"; }
function color::red() { echo -e "\033[0;31m$(color::reset "$1")"; }
function color::yellow() { echo -e "\033[0;33m$(color::reset "$1")"; }
function color::blue() { echo -e "\033[0;34m$(color::reset "$1")"; }
function log::log() { echo "📦 [$(date +'%Y-%m-%dT%H:%M:%S')] $1"; }
function log::error() { log::log "$(color::red "$1")" >&2; }
function log::warn() { log::log "$(color::yellow "$1")" >&2; }
function log::info() { log::log "$(color::blue "$1")"; }
function die() { log::error "$1" && exit "${2:-1}"; }

# ---

main "$@"
