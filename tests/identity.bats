#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  bats_load_library bats-support
  bats_load_library bats-assert

  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  fixture="$root/tests/fixtures/identity"
  cd "$root" || return
}

assert_raw() {
  local expected="$1"
  shift

  run --separate-stderr nix eval --no-write-lock-file --raw "$@"
  assert_success
  assert_output "$expected"
}

assert_override_raw() {
  local expected="$1"
  shift

  run --separate-stderr nix eval --no-write-lock-file \
    --override-input identity "path:$fixture" --raw "$@"
  assert_success
  assert_output "$expected"
}

assert_override_json() {
  local expected="$1"
  shift

  run --separate-stderr nix eval --no-write-lock-file \
    --override-input identity "path:$fixture" --json "$@"
  assert_success
  assert_output "$expected"
}

function fallback_identity_uses_conventional_platform_homes { #@test
  assert_raw "/Users/gtramontina" \
    .#darwinConfigurations.orion.config.home-manager.users.gtramontina.home.homeDirectory
  assert_raw "/home/gtramontina" \
    '.#homeConfigurations."gtramontina@cygnus".config.home.homeDirectory'
  assert_raw "Guilherme J. Tramontina" \
    .#darwinConfigurations.phoenix.config.users.users.gtramontina.description
}

function override_identity_flows_through_profiles_and_platforms { #@test
  assert_override_raw "/srv/home/colleague" \
    .#darwinConfigurations.orion.config.home-manager.users.colleague.home.homeDirectory
  assert_override_raw "/srv/home/colleague" \
    '.#homeConfigurations."colleague@cygnus".config.home.homeDirectory'
  assert_override_raw "personal@example.com" \
    .#darwinConfigurations.orion.config.home-manager.users.colleague.programs.git.settings.user.email
  assert_override_raw "work@example.com" \
    .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.settings.user.email
  assert_override_json "null" \
    .#darwinConfigurations.orion.config.home-manager.users.colleague.programs.git.signing.key
  assert_override_raw "AAAAAAAAAAAAAAAA" \
    .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.signing.key
  assert_override_json "true" \
    .#darwinConfigurations.phoenix.config.home-manager.users.colleague.programs.git.signing.signByDefault
  assert_override_raw $'cask_args require_sha: true\ncask_args appdir: "/srv/home/colleague/Applications"' \
    .#darwinConfigurations.phoenix.config.homebrew.extraConfig
}

function make_targets_only_use_an_existing_override { #@test
  local target
  for target in switch build check; do
    run make --no-print-directory -C "$BATS_TEST_TMPDIR" -f "$root/Makefile" -n "$target"
    assert_success
    refute_output --partial "--override-input identity"

    mkdir -p "$BATS_TEST_TMPDIR/identity.override"
    : >"$BATS_TEST_TMPDIR/identity.override/default.nix"
    run make --no-print-directory -C "$BATS_TEST_TMPDIR" -f "$root/Makefile" -n "$target"
    assert_success
    assert_output --partial "--override-input identity path:./identity.override"
    rm -rf "$BATS_TEST_TMPDIR/identity.override"
  done
}

function make_switch_bootstraps_the_platform_tool_through_nix { #@test
  local tool="home-manager"
  [[ $(uname -s) == Darwin ]] && tool="darwin-rebuild"

  run make --no-print-directory -n switch

  assert_success
  assert_output --partial "nix run"
  assert_output --partial ".#$tool"
}

function direct_override_evaluation_does_not_change_the_lock_file { #@test
  local lock_before
  lock_before="$(git hash-object flake.lock)"

  assert_override_raw "/srv/home/colleague" \
    .#darwinConfigurations.orion.config.home-manager.users.colleague.home.homeDirectory

  assert_equal "$(git hash-object flake.lock)" "$lock_before"
}
