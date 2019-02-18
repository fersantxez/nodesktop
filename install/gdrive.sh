#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Ocamlfuse"
#https://github.com/astrada/google-drive-ocamlfuse/wiki/Installation
 
add-apt-repository ppa:alessandro-strada/ppa

echo 'deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main' | \
    sudo tee /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list >/dev/null
#replace bionic at the end of both lines with xenial, for version > 0.6.21
sed -i 's/bionic/xenial/g' /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list

apt-get update
apt-get install google-drive-ocamlfuse
