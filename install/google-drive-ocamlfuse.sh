#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Ocamlfuse"
#https://github.com/astrada/google-drive-ocamlfuse/wiki/Installation
 
add-apt-repository ppa:alessandro-strada/ppa

#Correct downloaded deb list so that it points to xenial
ls /etc/apt/sources.list.d/
tee /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-jammy.list <<-EOF
deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu jammy main
deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu jammy main
EOF
#remove latest release downloaded
#rm /etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-lunar.list 

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AD5F235DF639B041
apt-get update
apt-get install -y google-drive-ocamlfuse

#Set up variable and directory for mounting Google Drive from script/desktop link
export GDRIVE_MOUNT_DIR=/headless/GoogleDrive
mkdir -p $GDRIVE_MOUNT_DIR
chmod 777 $GDRIVE_MOUNT_DIR

#Desktop icon
cat <<EOF > /headless/Desktop/gdrive.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Mount Google Drive
Comment=Mount your Google Drive
Exec="/headless/mount-google-drive.sh"
Icon=drive-removable-media
Path=
Terminal=false
StartupNotify=false
EOF
#Executable and trusted
chmod a+x /headless/Desktop/gdrive.desktop
gio set /headless/Desktop/gdrive.desktop "metadata::trusted" yes