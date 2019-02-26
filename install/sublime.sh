#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u

echo "Install Sublime Text"

sudo apt-get install apt-transport-https

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update -y

sudo apt-get install -y sublime-text