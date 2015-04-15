#!/usr/bin/env bash

spoons=~/.hammerspoon/Spoons
mkdir -p ${spoons}
curl -sL https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip | \
  tar xvz -C ${spoons}