#!/usr/bin/env bash
set -eu

echo "🌽 Installing NPM modules…"

command -v n >/dev/null || ((curl -L https://git.io/n-install | bash -s -- -y latest) && . ~/.zshrc)

modules=$(node -p "require(process.env.HOME+'/.cider/bootstrap')['npm-modules'].join('\n')")
npx yarn global add ${modules}
npx yarn global upgrade -L
npx yarn cache clean