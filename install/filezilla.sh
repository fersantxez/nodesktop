#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Filezilla FTP/SFTP Client"

apt-get install -y filezilla

#Desktop icon
f=/headless/Desktop/filezilla.desktop 
cat <<EOF > $f
[Desktop Entry]
Name=FileZilla
GenericName=FTP client
GenericName[de]=FTP-Client
GenericName[fr]=Client FTP
Comment=Download and upload files via FTP, FTPS and SFTP
Comment[de]=Dateien über FTP, FTPS und SFTP übertragen
Comment[fr]=Transférer des fichiers via FTP, FTPS et SFTP
Exec=filezilla
Terminal=false
Icon=filezilla
Type=Application
Categories=Network;FileTransfer;
Version=1.0
EOF
#Executable and trusted
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"