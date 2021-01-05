#!/usr/bin/env bash
set -eu

echo "🍻 Cleaning up homebrew…"
brew cleanup --prune=all -s
