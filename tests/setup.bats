#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file

  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  side_effect_log="$BATS_TEST_TMPDIR/side-effects.log"
}

function sourcing_setup_only_defines_its_interface { #@test
  export TEST_SIDE_EFFECT_LOG="$side_effect_log"

  run bash -c '
    function make() { printf "%s\n" "$*" >>"$TEST_SIDE_EFFECT_LOG"; }
    function nix() { printf "%s\n" "$*" >>"$TEST_SIDE_EFFECT_LOG"; }
    source "$1"
    declare -F main >/dev/null
  ' _ "$root/scripts/setup"

  assert_success
  assert_file_not_exist "$side_effect_log"
}

function setup_continues_after_installing_missing_nix { #@test
  local repository="$BATS_TEST_TMPDIR/repository"
  local commands="$BATS_TEST_TMPDIR/commands"
  local installed_bin="$BATS_TEST_TMPDIR/installed/bin"
  local install_log="$BATS_TEST_TMPDIR/install.log"
  local configure_log="$BATS_TEST_TMPDIR/configure.log"
  local profile_script="$BATS_TEST_TMPDIR/nix-profile.sh"

  mkdir -p "$repository/hosts" "$repository/identity" "$repository/scripts" "$commands" "$installed_bin"
  printf '%s\n' 'gtramontina/dotfiles' >"$repository/.dotfiles-root"
  : >"$repository/identity/default.nix"
  : >"$repository/flake.nix"
  : >"$repository/Makefile"
  : >"$repository/hosts/test-host.nix"
  cp "$root/scripts/setup" "$repository/scripts/setup"

  cat >"$installed_bin/nix" <<'EOF'
#!/bin/sh
if [ "${1:-}" = "--version" ]; then
  printf '%s\n' 'nix (Nix) 2.26.0'
  exit 0
fi
exit 1
EOF
  chmod +x "$installed_bin/nix"
  cat >"$profile_script" <<EOF
export PATH="$installed_bin:\$PATH"
export TEST_NIX_PROFILE_LOADED=1
EOF

  cat >"$commands/hostname" <<'EOF'
#!/bin/sh
printf '%s\n' test-host
EOF
  cat >"$commands/uname" <<'EOF'
#!/bin/sh
printf '%s\n' TestOS
EOF
  cat >"$commands/curl" <<'EOF'
#!/bin/sh
printf '%s\n' 'printf "%s\n" installed >"$TEST_NIX_INSTALL_LOG"'
EOF
  chmod +x "$commands/hostname" "$commands/uname" "$commands/curl"

  # shellcheck disable=SC2016
  run env \
    PATH="$commands:/usr/bin:/bin" \
    NIX_PROFILE_SCRIPT="$profile_script" \
    TEST_CONFIGURE_LOG="$configure_log" \
    TEST_NIX_INSTALL_LOG="$install_log" \
    /bin/bash -c '
      source "$1"
      directory="$2"
      function configure() { printf "%s:%s\n" "$1" "${TEST_NIX_PROFILE_LOADED:-0}" >"$TEST_CONFIGURE_LOG"; }
      main
    ' _ "$repository/scripts/setup" "$repository"

  assert_success
  assert_file_contains "$install_log" installed
  assert_file_contains "$configure_log" 'test-host:1'
}
