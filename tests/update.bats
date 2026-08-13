#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  bats_load_library bats-support
  bats_load_library bats-assert

  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  repository="$BATS_TEST_TMPDIR/repository"
  remote="$BATS_TEST_TMPDIR/remote.git"
  commands="$BATS_TEST_TMPDIR/commands"
  make_log="$BATS_TEST_TMPDIR/make.log"

  mkdir -p "$repository/scripts" "$commands"
  cp "$root/scripts/update" "$repository/scripts/update"
  printf 'initial\n' >"$repository/flake.lock"

  git init --quiet "$repository"
  git -C "$repository" checkout --quiet -b main
  git -C "$repository" config user.name "Test User"
  git -C "$repository" config user.email "test@example.com"
  git -C "$repository" config commit.gpgSign false
  git -C "$repository" add scripts/update flake.lock
  git -C "$repository" commit --quiet -m "Initial"

  git init --quiet --bare "$remote"
  git -C "$repository" remote add origin "$remote"
  git -C "$repository" push --quiet --set-upstream origin main

  cat >"$commands/make" <<'EOF'
#!/bin/bash
printf 'called\n' >>"$TEST_MAKE_LOG"
case "${TEST_UPDATE_MODE:-change}" in
  change) printf 'updated\n' >"$TEST_REPOSITORY/flake.lock" ;;
  extra) printf 'unexpected\n' >"$TEST_REPOSITORY/unexpected" ;;
  unchanged) ;;
esac
EOF
  chmod +x "$commands/make"
  : >"$make_log"

  export PATH="$commands:$PATH"
  export TEST_MAKE_LOG="$make_log"
  export TEST_REPOSITORY="$repository"
}

function update_refuses_a_dirty_worktree { #@test
  printf 'dirty\n' >"$repository/uncommitted"

  run "$repository/scripts/update"

  assert_failure
  assert_output --partial "uncommitted changes"
  assert_equal "" "$(<"$make_log")"
}

function update_reports_when_inputs_are_unchanged { #@test
  export TEST_UPDATE_MODE=unchanged

  run "$repository/scripts/update"

  assert_success
  assert_output --partial "already up to date"
  assert_equal "1" "$(git -C "$repository" rev-list --count HEAD)"
}

function update_aborts_if_more_than_the_lock_file_changes { #@test
  export TEST_UPDATE_MODE=extra

  run "$repository/scripts/update"

  assert_failure
  assert_output --partial "changes beyond flake.lock"
  assert_equal "1" "$(git -C "$repository" rev-list --count HEAD)"
}

function update_leaves_a_declined_lock_file_uncommitted { #@test
  run bash -c 'printf "n\n" | "$1"' _ "$repository/scripts/update"

  assert_success
  assert_output --partial "Commit and push updated flake inputs? [y/N]"
  assert_equal "1" "$(git -C "$repository" rev-list --count HEAD)"
  assert_equal " M flake.lock" "$(git -C "$repository" status --short)"
}

function update_commits_and_pushes_an_accepted_lock_file { #@test
  run bash -c 'printf "y\n" | "$1"' _ "$repository/scripts/update"

  assert_success
  assert_output --partial "Commit and push updated flake inputs? [y/N]"
  assert_equal "chore: update flake inputs" "$(git -C "$repository" log -1 --format=%s)"
  assert_equal "$(git -C "$repository" rev-parse HEAD)" "$(git --git-dir="$remote" rev-parse main)"
  assert_equal "" "$(git -C "$repository" status --short)"
}
