#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget curl net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    iputils-* htop locales software-properties-common dirmngr python3-numpy xscreensaver \
    zip unzip 

### Install rar, unrar
#wget \
#	http://ftp.us.debian.org/debian/pool/non-free/r/rar/rar_6.23-1~deb12u1_amd64.deb \
#    http://ftp.us.debian.org/debian/pool/non-free/u/unrar-nonfree/unrar_6.2.6-1+deb12u1_amd64.deb
#dpkg -i \
#	./rar* \
#	./unrar*

#ensure desktop dir exists before installers so that launchers can be added
mkdir -p /headless/Desktop/
chmod 777 /headless/Desktop
