#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Ocamlfuse"
#https://github.com/astrada/google-drive-ocamlfuse/wiki/Installation
 
add-apt-repository ppa:alessandro-strada/ppa

#Correct downloaded deb list so that it points to xenial
tee /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list <<-EOF
deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main
deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main
EOF
#remove disco release downloaded
rm /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-disco.list 

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
apt-get update
apt-get install google-drive-ocamlfuse

mkdir -p ~/GoogleDrive
chmod 777 ~/GoogleDrive
