#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget curl net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    iputils-* htop locales software-properties-common dirmngr python3-numpy xscreensaver arandr \
    gigolo \
    gvfs-fuse gvfs-backends openssl \
    zip unzip \
    python3-launchpadlib
    #padevchooser <-- Fix with pipewire?

### Install rar, unrar
wget \
	http://ftp.us.debian.org/debian/pool/non-free/r/rar/rar_6.23-1~deb12u1_amd64.deb \
    http://ftp.us.debian.org/debian/pool/non-free/u/unrar-nonfree/unrar_6.2.6-1+deb12u1_amd64.deb
dpkg -i \
	./rar* \
	./unrar*
