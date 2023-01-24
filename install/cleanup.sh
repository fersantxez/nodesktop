#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

sudo apt-get clean -y
#further clean - errors out
#sudo apt-get remove --purge -y --allow-remove-essential $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*

#fix statoverride for apt to work - remove crontab and Debian-exim groups
cat /var/lib/dpkg/statoverride | tail -n +3 > ./statoverride && \
sudo mv /var/lib/dpkg/statoverride /var/lib/dpkg/statoverride.bak && \
sudo mv ./statoverride /var/lib/dpkg/statoverride

#clean up home directory
sudo rm /headless/*rar*
#sudo rm /headless/wm_startup.sh #this breaks startup
sudo rm -Rf /headless/install
sudo rm -f /headless/core #FIXME -- where is this core coming from?
