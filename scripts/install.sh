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

	local os=$(uname -s)
	local current_host=$(hostname -s)
	log::info "OS: $os, Hostname: $current_host"

	local host_file="hosts/${current_host}.nix"
	if [[ -f "$host_file" ]]; then
		log::info "Existing configuration found for '$current_host'."
		echo
		echo "  (1) Re-apply current configuration"
		echo "  (2) Reconfigure (change settings)"
		echo "  (3) Abort"
		read -rp "Choose [1]: " choice
		case "$choice" in
			2) configure "$os" ;;
			3) exit 0 ;;
			*) setup ;;
		esac
	else
		configure "$os"
	fi
}

function configure() {
	local os="$1"
	local current_host=$(hostname -s)

	echo
	echo "── Configuration ──────────────────────────────"
	read -rp "Hostname [$current_host]: " hostname
	hostname="${hostname:-$current_host}"

	echo
	echo "Profile:"
	echo "  (1) personal"
	echo "  (2) work"
	read -rp "Choose [1]: " profile_choice
	local profile
	case "$profile_choice" in
		2) profile="work" ;;
		*) profile="personal" ;;
	esac

	local git_name="Guilherme J. Tramontina"
	local git_email
	if [[ "$profile" == "work" ]]; then
		read -rp "Git name [$git_name]: " input_name
		git_name="${input_name:-$git_name}"
		read -rp "Git email: " git_email
		[[ -z "$git_email" ]] && die "Git email is required for work profile."
	else
		read -rp "Git name [$git_name]: " input_name
		git_name="${input_name:-$git_name}"
		read -rp "Git email [guilherme.tramontina@gmail.com]: " git_email
		git_email="${git_email:-guilherme.tramontina@gmail.com}"
	fi

	mkdir -p hosts

	local host_content=""
	host_content+=$'{\n'
	host_content+=$'  imports = [\n'
	host_content+=$'    ../modules/home\n'
	host_content+=$'    ../modules/profiles/'"${profile}"$'.nix\n'
	if [[ "$os" == "Linux" ]]; then
		host_content+=$'    ../modules/linux\n'
	fi
	host_content+=$'  ];\n'
	host_content+=$'}\n'

	printf '%s' "$host_content" > "hosts/${hostname}.nix"

	local profile_file="modules/profiles/${profile}.nix"
	if [[ -f "$profile_file" ]]; then
		sed -i.bak "s/email = \"[^\"]*\"/email = \"${git_email}\"/" "$profile_file"
		rm -f "${profile_file}.bak"
	fi

	echo
	log::info "Configuration written for '$hostname' ($profile)."
	echo

	setup
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
function die() { log::error "$1" && exit "${2:-1}"; }

main "$@"
