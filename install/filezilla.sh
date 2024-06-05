#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Filezilla FTP/SFTP Client"

apt-get install -y filezilla

#Desktop icon
cat <<EOF > /headless/Desktop/filezilla.desktop 
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
chmod a+x /headless/Desktop/filezilla.desktop
dbus-launch gio set /headless/Desktop/filezilla.desktop "metadata::trusted" true