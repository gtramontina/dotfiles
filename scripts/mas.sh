#!/usr/bin/env bash

applications=$(ruby -e "require 'json';JSON.load(File.open('$HOME/.cider/bootstrap.json'))['apple-store'].each {|e|puts e}")
echo "Installing global App Store applications…"
for app in $applications; do mas lucky $app; done
