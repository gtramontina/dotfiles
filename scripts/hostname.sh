#!/usr/bin/env bash
set -eu

echo "👨‍🚀 Setting up hostname…"

hostname=gtramontina
sudo scutil --set HostName "${hostname}.local"
