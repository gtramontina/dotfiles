#!/bin/bash

set -eo pipefail

repository="https://github.com/gtramontina/dotfiles"

function main() {
	local host="$1"
	local directory="${2:-$HOME/.dotfiles}"

	[[ -n "$host" ]] || die "$(usage)"

	if [[ -d "$directory" ]]; then
		log::warn "The directory '$directory' already exists."
		confirm "Do you wish to continue with the setup?" || exit 0
	else
		log::info "Preparing '$directory'…"
		mkdir -p "$directory"

		log::info "Fetching contents from '$repository'…"
		curl -sL "$repository/tarball/main" | tar -xz --strip-components=1 -C "$directory"
		trap 'link_to_git' EXIT
	fi

	log::info "Running setup.sh from within '$directory'…"
	cd "$directory"
	./setup.sh "$host"
}

function link_to_git() {
	local directory
	directory="$(pwd)"

	log::info "Checking whether git is installed and '$directory' isn't a repository yet…"
	if [[ -n "$(command -v git)" ]] && [[ ! -d ".git" ]]; then
		log::info "Linking '$directory' to '$repository'…"
		git init
		git remote add origin "$repository.git"
		git fetch origin
		git reset --hard origin/main
	fi
}

# ---

function usage() { echo -e "Usage: $(basename "$0") <host> [directory]"; }

function color::reset() { echo -e "$1\033[0m"; }
function color::red() { echo -e "\033[0;31m$(color::reset "$1")"; }
function color::yellow() { echo -e "\033[0;33m$(color::reset "$1")"; }
function color::blue() { echo -e "\033[0;34m$(color::reset "$1")"; }
function color::bold() { echo -e "\033[1m$(color::reset "$1")"; }
function log::log() { echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $1"; }
function log::error() { log::log "$(color::red "$1")" >&2; }
function log::warn() { log::log "$(color::yellow "$1")" >&2; }
function log::info() { log::log "$(color::blue "$1")"; }

function confirm() { read -r -p "$(log::log "$(color::bold "$1")") [y/N] " response </dev/tty && [[ "$response" == "y" ]]; }
function die() { log::error "$1" && exit "${2:-1}"; }

# ---

main "$@"
