#!/bin/bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for test_script in "$root"/tests/test-*.sh; do
  printf '\n==> %s\n' "$(basename "$test_script")"
  "$test_script"
done

printf '\nAll behavior tests passed.\n'
