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
#remove latest release downloaded
rm /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-lunar.list 

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
apt-get update
apt-get install google-drive-ocamlfuse

#Set up variable and directory for mounting Google Drive from script/desktop link
export GDRIVE_MOUNT_DIR=/headless/GoogleDrive
mkdir -p $GDRIVE_MOUNT_DIR
chmod 777 $GDRIVE_MOUNT_DIR
