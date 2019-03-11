#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Tor"

sudo apt-get install -y tor

sudo mkdir -p /opt/tor
cd /opt/tor
sudo wget https://www.torproject.org/dist/torbrowser/8.0.6/tor-browser-linux64-8.0.6_en-US.tar.xz && \
sudo tar xf tor-browser-linux64-8.0.6_en-US.tar.xz && \
sudo rm -f tor-browser-linux64-8.0.6_en-US.tar.xz && \
sudo mv tor-browser_en-US/* /opt/tor && \
sudo rm -Rf tor-browser_en-US && \
sudo chmod a+x -R /opt/tor/ && \
sudo chown 5000:5000 -R /opt/tor && \
sudo ln -s /opt/tor/ /headless/Desktop/tor

#sudo apt-get install -y apt-transport-https

#Tor stretch repo
#tee /etc/apt/sources.list.d/tor-stretch.list <<-EOF
#deb     http://deb.torproject.org/torproject.org stretch main
#EOF
#gpg --keyserver keys.gnupg.net --recv-keys 886DDD89

#Tor Browser backport
#tee /etc/apt/sources.list.d/stretch-backports.list <<-EOF
#deb https://deb.torproject.org/torproject.org stretch main
#deb-src https://deb.torproject.org/torproject.org stretch main
#EOF

#curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
#gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

#apt-get update -y 
#apt-get install -y tor deb.torproject.org-keyring
#apt-get install -y torbrowser-launcher -t stretch-backports