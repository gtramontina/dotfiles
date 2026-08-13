#!/bin/bash

set -eo pipefail

repository="https://github.com/gtramontina/dotfilez"
directory="${DOTFILES_DIR:-$HOME/.dotfilez}"

function main() {
	if [[ -d "$directory/.git" ]]; then
		log::info "Repo already exists at '$directory', fetching updates…"
		cd "$directory"
		git fetch origin main --quiet
		git reset --hard origin/main --quiet
	else
		log::info "Cloning repository…"
		mkdir -p "$directory"
		git clone "$repository" "$directory"
		cd "$directory"
		trap 'link_to_git' EXIT
	fi

	local os
	os=$(uname -s)
	local current_host
	current_host=$(hostname -s)
	log::info "OS: $os, Hostname: $current_host"

	local host_file="hosts/${current_host}.nix"
	if [[ ! -f "$host_file" ]]; then
		log::error "No configuration found for host '$current_host'."
		echo
		echo "To add this machine:"
		echo "  1. Create hosts/${current_host}.nix (copy an existing host file, adjust profile)"
		echo "  2. Add an entry to flake.nix (mkDarwin or mkHome)"
		echo "  3. Commit and push"
		echo
		echo "Then run this installer again."
		exit 1
	fi

	configure "$current_host"
}

function configure() {
	local hostname="$1"
	local existing_profile
	existing_profile="$(detect_profile "$hostname")"

	echo
	echo "── Configuration ──────────────────────────────"
	log::info "Machine:  $hostname"
	log::info "Profile:  $existing_profile"
	echo

	local profile="$existing_profile"
	echo "Profile:"
	echo "  (1) personal"
	echo "  (2) work"
	read -rp "Confirm [$(echo $(( [[ "$profile" == "work" ]] && echo 2 || echo 1 )))]: " profile_choice
	case "$profile_choice" in
		2) profile="work" ;;
		1) profile="personal" ;;
	esac

	local git_name
	local git_email
	git_name="$(git_identity "$profile" name)"
	git_email="$(git_identity "$profile" email)"

	if [[ "$profile" == "work" ]]; then
		read -rp "Git name [$git_name]: " input_name
		git_name="${input_name:-$git_name}"
		read -rp "Git email [$git_email]: " input_email
		git_email="${input_email:-$git_email}"
	else
		read -rp "Git name [$git_name]: " input_name
		git_name="${input_name:-$git_name}"
		read -rp "Git email [$git_email]: " input_email
		git_email="${input_email:-$git_email}"
	fi

	echo
	echo "Summary:"
	echo "  Hostname:  $hostname"
	echo "  Profile:   $profile"
	echo "  Git name:  $git_name"
	echo "  Git email: $git_email"
	echo
	confirm "Apply this configuration?" || exit 0

	setup
}

function detect_profile() {
	local hostname="$1"
	local host_file="hosts/${hostname}.nix"
	local p
	p="$(grep -o 'profiles/[a-z]*' "$host_file" | head -1)"
	[[ -n "$p" ]] && p="${p#profiles/}"
	echo "${p:-personal}"
}

function git_identity() {
	local profile="$1"
	local field="$2"
	local profile_file="modules/profiles/${profile}.nix"
	local value
	value="$(grep -o "email = \"[^\"]*\"" "$profile_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)"/\1/')"
	if [[ "$field" == "name" ]]; then
		value="$(grep -o "name = \"[^\"]*\"" "$profile_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)"/\1/')"
	fi
	echo "${value:-}"
}

function setup() {
	if ! command -v nix &>/dev/null; then
		log::info "Installing Nix…"
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
		log::info "Nix installed successfully."
		log::warn "⚠️ Start a new shell and run this script again!"
		return 0
	fi

	make switch
}

function link_to_git() {
	local dir
	dir="$(pwd)"

	if [[ -n "$(command -v git)" ]] && [[ ! -d ".git" ]]; then
		log::info "Linking '$dir' to '$repository'…"
		git init
		git remote add origin "$repository.git"
		git fetch origin
		git reset --hard origin/main
	fi
}

function usage() { echo -e "Usage: $(basename "$0")"; }

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

main "$@"