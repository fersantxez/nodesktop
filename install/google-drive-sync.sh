#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive Sync"

#deps
apt-get install -y \
	libdbusmenu-glib4 \
	libdbusmenu-gtk4 \
	libindicator7 \
	libpango1.0-0 \
	libwebkitgtk-1.0-0 

#drive-sync
DOWNLOAD_URI=https://storage.googleapis.com/nodesktop/Software/System/drive-sync_3.47.7484.7992_amd64.deb

curl -O $DOWNLOAD_URI
sudo dpkg -i ./drive-sync* 
&& \
sudo rm -f ./drive-sync*

#add required "en_GB" locale
sudo sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
