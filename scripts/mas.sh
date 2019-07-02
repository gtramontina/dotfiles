#!/usr/bin/env bash
set -eu

echo "🍎Installing App Store applications…"

applications=$(ruby -e "require 'json';JSON.load(File.open('$HOME/.cider/bootstrap.json'))['apple-store'].each {|e|puts e}")
for app in ${applications}; do mas lucky "$app"; done
