#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit

echo "Installing zsh"
apt update && apt install zsh -y
chsh -s $(which zsh) sysadm

echo "Installing ohmyzsh"
# todo: run it for sysadm
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"