#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget curl net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    iputils-* transmission htop locales software-properties-common dirmngr python3-numpy xscreensaver arandr \
    gigolo gvfs-fuse gvfs-backends openssl filezilla zip unzip
apt-get clean -y

### Install rar, unrar
wget \
	http://ftp.us.debian.org/debian/pool/non-free/r/rar/rar_5.4.0%2Bdfsg.1-0.1_amd64.deb \
	http://ftp.us.debian.org/debian/pool/non-free/u/unrar-nonfree/unrar_5.3.2-1+deb9u1_amd64.deb

dpkg -i \
	./rar* \
	./unrar*

### Bashtop
wget https://github.com/aristocratos/btop/releases/download/v1.2.13/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
mv btop/bin/btop /usr/btop
rm -Rf btop*