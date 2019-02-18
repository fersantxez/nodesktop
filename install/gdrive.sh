#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Ocamlfuse"
#https://www.ostechnix.com/how-to-mount-google-drive-locally-as-virtual-file-system-in-linux/

apt install software-properties-common dirmngr gnupg-agent
add-apt-repository ppa:alessandro-strada/ppa

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
echo 'deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main' | sudo tee /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa.list >/dev/null
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse
