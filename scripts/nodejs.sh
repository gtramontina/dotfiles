#!/usr/bin/env bash
set -eu

echo "🌽 Installing NPM modules…"

RC=$(mktemp -t rcfile); cat << EOF > $RC
    n latest
    rm -f $RC
EOF
zsh --rcs $RC
unset RC

modules=$(node -p "require(process.env.HOME+'/.cider/bootstrap')['npm-modules'].join('\n')")
npx yarn global add ${modules}
npx yarn global upgrade -L
