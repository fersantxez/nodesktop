#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Bash-it"

git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
~/.bash_it/install.sh --silent && \
sed -i -e 's/bobby/zork/g' /headless/.bashrc

