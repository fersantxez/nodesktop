#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Tor"

sudo apt-get install -y tor

TOR_VERSION=12.0.2
TOR_URI=https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz

sudo mkdir -p /opt/tor
cd /opt/tor
sudo wget ${TOR_URI} && \
sudo tar xf tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz && \
sudo rm -f tor-browser-linux64-${TOR_VERSION}_ALL.tar.xz && \
sudo mv tor-browser/* /opt/tor && \
sudo rm -Rf tor-browser && \
sudo chmod a+x -R /opt/tor/ && \
sudo chown 1000:1000 -R /opt/tor && \
mkdir -p /headless/Desktop

cat <<EOF >> /headless/Desktop/tor.desktop 
[Desktop Entry] 
Type=Application
Name=Tor Browser Setup
GenericName=Web Browser
Comment=Tor Browser is +1 for privacy and −1 for mass surveillance
Categories=Network;WebBrowser;Security;
Exec=sh -c /opt/tor/Browser/start-tor-browser --detach
X-TorBrowser-ExecShell=./Browser/start-tor-browser --detach
Icon=tor-browser
StartupWMClass=Tor Browser
EOF
sudo chown 1000:1000 /headless/Desktop/
sudo chown 1000:1000 /headless/Desktop/tor.desktop
