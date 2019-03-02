#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

sudo apt-get clean -y
#further clean - errors out
#sudo apt-get remove --purge -y --allow-remove-essential $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*