#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  bats_load_library bats-support
  bats_load_library bats-assert

  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  repository="$BATS_TEST_TMPDIR/repository"
  publisher="$BATS_TEST_TMPDIR/publisher"
  remote="$BATS_TEST_TMPDIR/remote.git"
  commands="$BATS_TEST_TMPDIR/commands"
  make_log="$BATS_TEST_TMPDIR/make.log"
  reexec_log="$BATS_TEST_TMPDIR/reexec.log"

  mkdir -p "$repository/scripts" "$commands"
  cp "$root/scripts/sync" "$repository/scripts/sync"

  git init --quiet "$repository"
  git -C "$repository" checkout --quiet -b main
  configure_git "$repository"
  git -C "$repository" add scripts/sync
  git -C "$repository" commit --quiet -m "Initial"

  git init --quiet --bare "$remote"
  git -C "$repository" remote add origin "$remote"
  git -C "$repository" push --quiet --set-upstream origin main
  git clone --quiet --branch main "$remote" "$publisher"
  configure_git "$publisher"

  cat >"$commands/make" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_MAKE_LOG"
EOF
  chmod +x "$commands/make"
  : >"$make_log"

  export PATH="$commands:$PATH"
  export TEST_MAKE_LOG="$make_log"
  export TEST_REEXEC_LOG="$reexec_log"
}

function configure_git() {
  local directory="$1"
  git -C "$directory" config user.name "Test User"
  git -C "$directory" config user.email "test@example.com"
  git -C "$directory" config commit.gpgSign false
}

function push_remote_change() {
  printf 'remote change\n' >"$publisher/configuration"
  git -C "$publisher" add configuration
  git -C "$publisher" commit --quiet -m "Remote change"
  git -C "$publisher" push --quiet
}

function sync_refuses_a_dirty_worktree { #@test
  printf 'dirty\n' >"$repository/uncommitted"

  run "$repository/scripts/sync"

  assert_failure
  assert_output --partial "uncommitted changes"
  assert_equal "" "$(<"$make_log")"
}

function sync_fast_forwards_and_switches { #@test
  push_remote_change

  run "$repository/scripts/sync"

  assert_success
  assert_equal "$(git --git-dir="$remote" rev-parse main)" "$(git -C "$repository" rev-parse HEAD)"
  assert_equal "switch" "$(<"$make_log")"
}

function sync_stops_when_fast_forwarding_is_impossible { #@test
  push_remote_change
  printf 'local change\n' >"$repository/local"
  git -C "$repository" add local
  git -C "$repository" commit --quiet -m "Local change"

  run "$repository/scripts/sync"

  assert_failure
  assert_equal "" "$(<"$make_log")"
}

function sync_reexecutes_the_pulled_script_before_switching { #@test
  cat >"$publisher/scripts/sync" <<'EOF'
#!/bin/bash
printf 'new script\n' >"$TEST_REEXEC_LOG"
make switch
EOF
  chmod +x "$publisher/scripts/sync"
  git -C "$publisher" add scripts/sync
  git -C "$publisher" commit --quiet -m "Change sync behavior"
  git -C "$publisher" push --quiet

  run "$repository/scripts/sync"

  assert_success
  assert_equal "new script" "$(<"$reexec_log")"
  assert_equal "switch" "$(<"$make_log")"
}
