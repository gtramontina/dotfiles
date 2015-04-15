#!/usr/bin/env bash

RC=$(mktemp -t rcfile); cat << EOF > $RC
    n latest
    rm -f $RC
EOF
zsh --rcs $RC
unset RC

modules=$(node -p "require(process.env.HOME+'/.cider/bootstrap')['npm-modules'].join('\n')")
echo "Installing global NPM modules…"
npx yarn global add $(echo $modules)
npx yarn global upgrade -L
