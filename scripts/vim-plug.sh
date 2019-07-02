#!/usr/bin/env bash
set -eu

echo "⌨️ Installing VIM plugins…"

curl -s -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
