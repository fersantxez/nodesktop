#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Odrive (Oxygen Drive)"

#Download and install agent
od="/headless/.odrive-agent/bin" && \
curl -L "https://dl.odrive.com/odrive-py" \
--create-dirs \
-o "$od/odrive.py" && \
curl -L "https://dl.odrive.com/odriveagent-lnx-64" | tar -xvzf- -C "$od/" && \
curl -L "https://dl.odrive.com/odrivecli-lnx-64" | tar -xvzf- -C "$od/" && \
ln -s "$od"/odriveagent /usr/bin/odriveagent && \
ln -s "$od"/odrive /usr/bin/odrive

#Desktop icon
f=/headless/Desktop/odrive.desktop 
cat <<EOF > $f
[Desktop Entry]
Version=1.0
Type=Application
Name=odrive
Comment=Mount and Manage Cloud Storage Drives
Exec="/headless/mount-odrive.sh"
Icon=downloads
Path="/headless/"
Terminal=true
StartupNotify=false
EOF
#Executable and trusted
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"