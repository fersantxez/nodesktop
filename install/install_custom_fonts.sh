#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Installing fonts"
apt-get install -y ttf-wqy-zenhei fonts-inconsolata
