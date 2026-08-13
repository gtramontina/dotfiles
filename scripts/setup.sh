#!/bin/bash

set -eo pipefail

function main() {
	if ! command -v nix &>/dev/null; then
		log::info "Installing Nix…"
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
		log::info "Nix installed successfully."
		log::warn "⚠️ Start a new shell and run this script again!"
		return 0
	fi

	make switch
}

function color::reset() { echo -e "$1\033[0m"; }
function color::red() { echo -e "\033[0;31m$(color::reset "$1")"; }
function color::yellow() { echo -e "\033[0;33m$(color::reset "$1")"; }
function color::blue() { echo -e "\033[0;34m$(color::reset "$1")"; }
function log::log() { echo "📦 [$(date +'%Y-%m-%dT%H:%M:%S')] $1"; }
function log::error() { log::log "$(color::red "$1")" >&2; }
function log::warn() { log::log "$(color::yellow "$1")" >&2; }
function log::info() { log::log "$(color::blue "$1")"; }
function die() { log::error "$1" && exit "${2:-1}"; }

main "$@"
