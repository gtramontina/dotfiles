#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file

  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  repository="$BATS_TEST_TMPDIR/repository"
  setup_log="$BATS_TEST_TMPDIR/setup.log"

  mkdir -p "$BATS_TEST_TMPDIR/home" "$BATS_TEST_TMPDIR/git-template"
  export HOME="$BATS_TEST_TMPDIR/home"
  export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  export GIT_TEMPLATE_DIR="$BATS_TEST_TMPDIR/git-template"
  unset GIT_DIR GIT_INDEX_FILE GIT_WORK_TREE

  mkdir -p "$repository/scripts"
  git -C "$repository" init --quiet
  printf '%s\n' 'gtramontina/dotfiles' >"$repository/.dotfiles-root"
  cat >"$repository/scripts/setup" <<'EOF'
#!/bin/sh
printf '%s\n' setup >"$TEST_SETUP_LOG"
EOF
  chmod +x "$repository/scripts/setup"
}

function interactive_helper_resolves_expect_from_path { #@test
  local shebang
  IFS= read -r shebang <"$root/tests/helpers/install-interactive"

  assert_equal "$shebang" "#!/usr/bin/env expect"
}

function piped_installer_delegates_to_the_checked_out_setup { #@test
  export DOTFILES_DIR="$repository"
  export TEST_SETUP_LOG="$setup_log"

  run /bin/bash -o pipefail -c 'cat "$1" | /bin/bash' _ "$root/scripts/install"

  assert_success
  assert_file_contains "$setup_log" setup
}

function installer_rejects_a_mismatched_repository_marker { #@test
  export DOTFILES_DIR="$repository"
  export TEST_SETUP_LOG="$setup_log"
  printf '%s\n' 'someone/else' >"$repository/.dotfiles-root"

  run /bin/bash -o pipefail -c 'cat "$1" | /bin/bash' _ "$root/scripts/install"

  assert_failure
  assert_file_not_exist "$setup_log"
}

function piped_installer_clones_before_delegating { #@test
  local commands="$BATS_TEST_TMPDIR/clone-commands"
  local clone_log="$BATS_TEST_TMPDIR/clone.log"
  mkdir -p "$commands"
  rm -rf "$repository"

  cat >"$commands/git" <<'EOF'
#!/bin/sh
if [ "${1:-}" = "-C" ]; then
  exit 1
fi
if [ "${1:-}" = "clone" ]; then
  mkdir -p "$3/scripts"
  printf '%s\n' 'gtramontina/dotfiles' >"$3/.dotfiles-root"
  cat >"$3/scripts/setup" <<'SETUP'
#!/bin/sh
printf '%s\n' setup >"$TEST_SETUP_LOG"
SETUP
  chmod +x "$3/scripts/setup"
  printf '%s\n%s\n' "$2" "$3" >"$TEST_CLONE_LOG"
  exit 0
fi
exit 1
EOF
  chmod +x "$commands/git"

  export DOTFILES_DIR="$repository"
  export TEST_CLONE_LOG="$clone_log"
  export TEST_SETUP_LOG="$setup_log"

  # shellcheck disable=SC2016
  run env PATH="$commands:/usr/bin:/bin" /bin/bash -o pipefail -c 'cat "$1" | /bin/bash' _ "$root/scripts/install"

  assert_success
  assert_file_contains "$clone_log" 'https://github.com/gtramontina/dotfiles'
  assert_file_contains "$clone_log" "$repository"
  assert_file_contains "$setup_log" setup
}

function piped_installer_configures_and_reuses_local_identity { #@test
  local commands="$root/tests/fixtures/commands"
  local old_nix="$root/tests/fixtures/old-nix"
  local installer="$root/scripts/install"
  local interactive="$root/tests/helpers/install-interactive"
  local make_log="$BATS_TEST_TMPDIR/make.log"
  local real_make
  local real_nix
  real_make="$(command -v make)"
  real_nix="$(command -v nix)"

  rm -rf "$repository"
  mkdir -p "$repository"
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

  "$interactive" first "$installer"

  local identity_file="$repository/identity.override/default.nix"
  assert_file_exist "$identity_file"
  assert_equal "test-user" "$(nix eval --raw --file "$identity_file" username)"
  assert_equal "$HOME" "$(nix eval --raw --file "$identity_file" homeDirectory)"
  assert_equal "$repository" "$(nix eval --raw --file "$identity_file" dotfilesDirectory)"
  assert_equal 'Jane "Q" \ Tester' "$(nix eval --raw --file "$identity_file" fullName)"
  assert_equal "jane@example.com" "$(nix eval --raw --file "$identity_file" profiles.personal.email)"
  assert_equal "jane@work.example.com" "$(nix eval --raw --file "$identity_file" profiles.work.email)"
  assert_equal "" "$(nix eval --raw --file "$identity_file" profiles.personal.signingKey)"
  assert_equal "0xAAAAAAAAAAAAAAAA!" "$(nix eval --raw --file "$identity_file" profiles.work.signingKey)"
  assert_equal "switch" "$(<"$make_log")"

  local identity_hash
  identity_hash="$(git hash-object "$identity_file")"
  "$interactive" rerun "$installer"
  assert_equal "$identity_hash" "$(git hash-object "$identity_file")"
  assert_equal $'switch\nswitch' "$(<"$make_log")"

  local lock_hash
  lock_hash="$(git -C "$repository" hash-object flake.lock)"
  "$real_make" --no-print-directory -C "$repository" check
  assert_equal "$lock_hash" "$(git -C "$repository" hash-object flake.lock)"

  export TEST_REAL_NIX="$real_nix"
  export TEST_NIX_VERSION="2.26.0"
  PATH="$old_nix:$commands:$PATH" "$interactive" rerun "$installer"
  assert_equal $'switch\nswitch\nswitch' "$(<"$make_log")"

  export TEST_NIX_VERSION="2.25.5"
  # shellcheck disable=SC2016
  run env PATH="$old_nix:$commands:$PATH" /bin/bash -o pipefail -c 'cat "$1" | /bin/bash' _ "$installer"
  assert_failure
  assert_output --partial "Nix 2.26 or newer is required"
  assert_equal $'switch\nswitch\nswitch' "$(<"$make_log")"
}
