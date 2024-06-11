#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Transmission BitTorrent client"

apt-get install -y transmission-gtk

#Desktop icon
f=/headless/Desktop/transmission-gtk.desktop 
cat <<EOF > $f
[Desktop Entry]
Name=Transmission
GenericName=BitTorrent Client
X-GNOME-FullName=Transmission BitTorrent Client
Comment=Download and share files over BitTorrent
Exec=transmission-gtk %U
Icon=transmission
Terminal=false
TryExec=transmission-gtk
Type=Application
StartupNotify=true
MimeType=application/x-bittorrent;x-scheme-handler/magnet;
Categories=Network;FileTransfer;P2P;GTK;
X-Ubuntu-Gettext-Domain=transmission
X-AppInstall-Keywords=torrent
Actions=Pause;Minimize;

[Desktop Action Pause]
Name=Start Transmission with All Torrents Paused
Exec=transmission-gtk --paused

[Desktop Action Minimize]
Name=Start Transmission Minimized
Exec=transmission-gtk --minimized
EOF
#Executable and trusted
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"