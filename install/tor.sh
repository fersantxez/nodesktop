#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Tor"

sudo apt-get install -y tor

#Tor stretch repo
tee /etc/apt/sources.list.d/tor-stretch.list <<-EOF
deb     http://deb.torproject.org/torproject.org stretch main
EOF

#Tor Browser backport
tee /etc/apt/sources.list.d/stretch-backports.list <<-EOF
deb http://deb.debian.org/debian stretch-backports main contrib
EOF

gpg --keyserver keys.gnupg.net --recv-keys 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt-get update -y 
apt-get install -y deb.torproject.org-keyring
apt-get install -y tor  
apt-get install -y torbrowser-launcher -t stretch-backports