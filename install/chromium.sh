#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Chromium"
apt install -y chromium
