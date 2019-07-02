#!/usr/bin/env bash
set -eu

echo "👢 Defining login items…"

osascript -e 'tell application "System Events" to make login item at end with properties {path: "/Applications/Hammerspoon.app", name: "Hammerspoon"}'
