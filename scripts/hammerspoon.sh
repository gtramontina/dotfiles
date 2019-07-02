#!/usr/bin/env bash
set -eu

echo "🥄 Installing default Hammerspoon Spoons…"

spoons=~/.hammerspoon/Spoons
mkdir -p ${spoons}
curl -sL https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip | \
  tar xvz -C ${spoons}