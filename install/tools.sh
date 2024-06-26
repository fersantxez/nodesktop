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
    dbus-x11
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
f=/headless/Desktop/arandr.desktop
cat <<EOF >> $f 
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
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"

f=/headless/Desktop/gigolo.desktop 
cat <<EOF >> $f
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
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"
