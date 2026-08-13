#!/bin/bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$root/tests/fixtures/identity"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT

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

function eval_raw() {
  nix eval --no-write-lock-file --raw "$@"
}

function eval_override_raw() {
  nix eval --no-write-lock-file --override-input identity "path:$fixture" --raw "$@"
}

function eval_override_json() {
  nix eval --no-write-lock-file --override-input identity "path:$fixture" --json "$@"
}

cd "$root"
lock_before="$(git hash-object flake.lock)"

assert_equal "/Users/gtramontina" \
  "$(eval_raw .#darwinConfigurations.orion.config.home-manager.users.gtramontina.home.homeDirectory)" \
  "fallback Darwin home"
assert_equal "/home/gtramontina" \
  "$(eval_raw '.#homeConfigurations."gtramontina@cygnus".config.home.homeDirectory')" \
  "fallback Linux home"
assert_equal "Guilherme J. Tramontina" \
  "$(eval_raw .#darwinConfigurations.phoenix.config.users.users.gtramontina.description)" \
  "fallback Darwin description"

assert_equal "/srv/home/colleague" \
  "$(eval_override_raw .#darwinConfigurations.orion.config.home-manager.users.colleague.home.homeDirectory)" \
  "override Darwin home"
assert_equal "/srv/home/colleague" \
  "$(eval_override_raw '.#homeConfigurations."colleague@cygnus".config.home.homeDirectory')" \
  "override Linux home and output name"
assert_equal "personal@example.com" \
  "$(eval_override_raw .#darwinConfigurations.orion.config.home-manager.users.colleague.programs.git.settings.user.email)" \
  "personal profile email"
assert_equal "work@example.com" \
  "$(eval_override_raw .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.settings.user.email)" \
  "work profile email"
assert_equal "null" \
  "$(eval_override_json .#darwinConfigurations.orion.config.home-manager.users.colleague.programs.git.signing.key)" \
  "empty signing key disables personal signing"
assert_equal "AAAAAAAAAAAAAAAA" \
  "$(eval_override_raw .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.signing.key)" \
  "work signing key"
assert_equal "true" \
  "$(eval_override_json .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.signing.signByDefault)" \
  "work signing enabled"
assert_equal $'cask_args require_sha: true\ncask_args appdir: "/srv/home/colleague/Applications"' \
  "$(eval_override_raw .#darwinConfigurations.phoenix.config.homebrew.extraConfig)" \
  "Homebrew uses override home"

for target in switch build check; do
  without_override="$(make --no-print-directory -C "$temporary_directory" -f "$root/Makefile" -n "$target")"
  if [[ $without_override == *"--override-input identity"* ]]; then
    printf 'FAIL: make %s used a missing override\n' "$target" >&2
    exit 1
  fi

  mkdir -p "$temporary_directory/identity.override"
  : >"$temporary_directory/identity.override/default.nix"
  with_override="$(make --no-print-directory -C "$temporary_directory" -f "$root/Makefile" -n "$target")"
  if [[ $with_override != *"--override-input identity path:./identity.override"* ]]; then
    printf 'FAIL: make %s did not use the local override\n' "$target" >&2
    exit 1
  fi
  rm -rf "$temporary_directory/identity.override"
  printf 'PASS: make %s override detection\n' "$target"
done

assert_equal "$lock_before" "$(git hash-object flake.lock)" "override leaves flake.lock unchanged"
