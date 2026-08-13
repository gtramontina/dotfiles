#!/bin/bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT

repository="$temporary_directory/repository"
test_home="$temporary_directory/home"
make_log="$temporary_directory/make.log"
commands="$root/tests/fixtures/commands"
old_nix="$root/tests/fixtures/old-nix"
real_make="$(command -v make)"
real_nix="$(command -v nix)"

function fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

function assert_equal() {
  local expected="$1"
  local actual="$2"
  local description="$3"
  if [[ $actual != "$expected" ]]; then
    printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$description" "$expected" "$actual" >&2
    exit 1
  fi
  printf 'PASS: %s\n' "$description"
}

mkdir -p "$repository" "$test_home" "$temporary_directory/git-template"
export HOME="$test_home"
export GIT_CONFIG_GLOBAL="$test_home/.gitconfig"
export GIT_CONFIG_NOSYSTEM=1
export GIT_TEMPLATE_DIR="$temporary_directory/git-template"
unset GIT_DIR GIT_INDEX_FILE GIT_WORK_TREE

rsync -a \
  --exclude '/.git/' \
  --exclude '/.cache/' \
  --exclude '/identity.override/' \
  --exclude '/result' \
  "$root/" "$repository/"
cp "$repository/hosts/orion.nix" "$repository/hosts/test-host.nix"

git -C "$repository" init --quiet
git -C "$repository" config user.name "Installer Test"
git -C "$repository" config user.email "installer@example.com"
git -C "$repository" config commit.gpgSign false
git -C "$repository" add .
git -C "$repository" commit --quiet -m fixture

git config --global user.name "Git Default"
git config --global user.email "git-default@example.com"
git config --global user.signingkey "AAAAAAAAAAAAAAAA"

export DOTFILES_DIR="$repository"
export TEST_HOSTNAME="test-host"
export TEST_USERNAME="test-user"
export TEST_MAKE_LOG="$make_log"
export PATH="$commands:$PATH"

expect "$root/tests/install.exp" first "$repository/scripts/install.sh"

identity_file="$repository/identity.override/default.nix"
[[ -f $identity_file ]] || fail "installer did not create the identity override"
assert_equal "test-user" "$(nix eval --raw --file "$identity_file" username)" "installer records login username"
assert_equal "$test_home" "$(nix eval --raw --file "$identity_file" homeDirectory)" "installer records actual home"
assert_equal 'Jane "Q" \ Tester' "$(nix eval --raw --file "$identity_file" fullName)" "installer safely serializes strings"
assert_equal "jane@example.com" "$(nix eval --raw --file "$identity_file" profiles.personal.email)" "installer records personal email"
assert_equal "jane@work.example.com" "$(nix eval --raw --file "$identity_file" profiles.work.email)" "installer records work email"
assert_equal "" "$(nix eval --raw --file "$identity_file" profiles.personal.signingKey)" "installer clears a signing key"
assert_equal "0xAAAAAAAAAAAAAAAA!" "$(nix eval --raw --file "$identity_file" profiles.work.signingKey)" "installer accepts a full GPG selector"
assert_equal "switch" "$(<"$make_log")" "installer applies the configuration"

identity_hash="$(git hash-object "$identity_file")"
expect "$root/tests/install.exp" rerun "$repository/scripts/install.sh"
assert_equal "$identity_hash" "$(git hash-object "$identity_file")" "rerun preserves accepted defaults"
assert_equal $'switch\nswitch' "$(<"$make_log")" "each installer run switches exactly once"

lock_hash="$(git -C "$repository" hash-object flake.lock)"
"$real_make" --no-print-directory -C "$repository" check
assert_equal "$lock_hash" "$(git -C "$repository" hash-object flake.lock)" "make check with an override preserves flake.lock"

export TEST_REAL_NIX="$real_nix"
export TEST_NIX_VERSION="2.26.0"
PATH="$old_nix:$commands:$PATH" expect "$root/tests/install.exp" rerun "$repository/scripts/install.sh"
assert_equal $'switch\nswitch\nswitch' "$(<"$make_log")" "installer accepts the Nix 2.26 boundary"

export TEST_NIX_VERSION="2.25.5"
if old_nix_output="$(PATH="$old_nix:$commands:$PATH" bash "$repository/scripts/install.sh" 2>&1)"; then
  fail "installer accepted Nix 2.25"
fi
if [[ $old_nix_output != *"Nix 2.26 or newer is required"* ]]; then
  fail "installer did not explain the minimum Nix version"
fi
assert_equal $'switch\nswitch\nswitch' "$(<"$make_log")" "unsupported Nix stops before applying"
