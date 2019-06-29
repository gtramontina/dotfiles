#!/usr/bin/env bash
set -eu

# Inspired by https://github.com/NicolasBernaerts/ubuntu-scripts/blob/master/mozilla/firefox-extension-manager
function install_extension() {
    local extension
    local destination
    local html
    local uid
    local name
    local version
    local xpi
    local target

    extension="https://addons.mozilla.org/en-US/firefox/addon/$1"
    destination=$2
    html=$(curl -sL "${extension}")
    uid=$(echo "${html}" | tr ',' '\n' | grep -m 1 "^\"guid\"" | cut -d'"' -f4)
    name=$(echo "${html}" | tr ',' '\n' | grep -m 1 "^\"name\"" | cut -d'"' -f4)
    version=$(echo "${html}" | tr ',' '\n' | grep -m 1 "^\"version\"" | cut -d'"' -f4)
    xpi=$(echo "${html}" | tr ',' '\n' | grep "^\"url\"" | grep ".xpi" | head -n 1 | cut -d'"' -f4 | sed "s|u002F||g" | tr '\\' '/')
    target="${destination}/${uid}.xpi"

    [ -f "${target}" ] && rm "${target}"
    echo "» Installing '${name}' version ${version} (${uid})…"
    wget --quiet -O "${target}" "${xpi}"
}
export -f install_extension

# ---

user_home="${HOME}/Library/Application Support/Firefox"
[ -d "${user_home}/Crash Reports" ] || (open -a Firefox; sleep 5; killall firefox)

user_profile=$(grep "Path=" "${user_home}/profiles.ini" | head -n 1 | cut -d'=' -f2)
user_path="${user_home}/${user_profile}/extensions"
[ -d "${user_path}" ] || mkdir -p "${user_path}"

echo "🦊 Installing firefox extensions…"
extensions=$(ruby -e "require 'json';JSON.load(File.open('${HOME}/.cider/bootstrap.json'))['firefox-extensions'].each {|e|puts e}")
echo "${extensions}" | xargs -n 1 -P 10 -I {} bash -c "install_extension \"{}\" \"${user_path}\""