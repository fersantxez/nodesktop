#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget curl net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    iputils-* htop locales software-properties-common dirmngr python3-numpy xscreensaver arandr \
    gigolo \
    gvfs-fuse gvfs-backends openssl \
    zip unzip \
    python3-launchpadlib \
    #padevchooser <-- Fix with pipewire?

### Install rar, unrar
wget \
	http://ftp.us.debian.org/debian/pool/non-free/r/rar/rar_6.23-1~deb12u1_amd64.deb \
    http://ftp.us.debian.org/debian/pool/non-free/u/unrar-nonfree/unrar_6.2.6-1+deb12u1_amd64.deb
dpkg -i \
	./rar* \
	./unrar*

#ensure desktop dir exists before installers so that launchers can be added
mkdir -p /headless/Desktop/
chmod 777 /headless/Desktop

#Desktop Icons for select tools
cat <<EOF >> /headless/Desktop/arandr.desktop 
[Desktop Entry]
Version=1.0
Type=Application
Name=Change Resolution
Comment=Change screen size with arandr
Exec=arandr
Icon=view-fullscreen-symbolic
Path=
Terminal=false
StartupNotify=false
EOF
#Executable and trusted
chmod a+x /headless/Desktop/arandr.desktop
dbus-x11 gio set /headless/Desktop/arandr.desktop "metadata::trusted" true

cat <<EOF >> /headless/Desktop/gigolo.desktop 
[Desktop Entry]
Version=1.0
Type=Application
Name=Mount Remote Filesystems
Comment=Mount Remote Filesystems with Gigolo
Exec=gigolo
Icon=network-workgroup
Path=
Terminal=false
StartupNotify=false
EOF
#Executable and trusted
chmod a+x /headless/Desktop/gigolo.desktop
gio set /headless/Desktop/gigolo.desktop "metadata::trusted" yes
