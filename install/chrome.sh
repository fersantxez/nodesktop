#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb
