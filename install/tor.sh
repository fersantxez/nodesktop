#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Tor"

sudo apt-get install -y tor

TOR_VERSION=13.0.15
TOR_URI=https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz

sudo mkdir -p /opt/tor
cd /opt/tor
sudo wget ${TOR_URI} && \
sudo tar xf tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz && \
sudo rm -f tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz && \
sudo mv tor-browser/* /opt/tor && \
sudo rm -Rf tor-browser && \
sudo chmod a+x -R /opt/tor/ && \
sudo chown 1000:1000 -R /opt/tor

