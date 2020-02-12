#!/usr/bin/env bash
set -eu

echo "🍎Installing App Store applications…"

applications=$(ruby -e "require 'json';JSON.load(File.open('$HOME/.cider/bootstrap.json'))['apple-store-id'].each {|e|puts e}")
for id in ${applications}; do mas install "$id"; done
