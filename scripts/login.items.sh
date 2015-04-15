#!/usr/bin/env bash
set -eu

osascript -e 'tell application "System Events" to make login item at end with properties {path: "/Applications/Hammerspoon.app", name: "Hammerspoon"}'
