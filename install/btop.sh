#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install btop (Bashtop C++)"

wget https://github.com/aristocratos/btop/releases/download/v1.3.2/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
mv btop/bin/btop /usr/bin/btop
rm -Rf btop*

#Desktop icon
cat <<EOF > /headless/Desktop/btop.desktop 
[Desktop Entry]
Version=1.0
Type=Application
Name=btop
Comment=Display information about the running system
Exec=btop
Icon=utilities-system-monitor
Path=
Terminal=true
StartupNotify=false
EOF
#Executable and trusted
chmod a+x /headless/Desktop/btop.desktop
dbus-launch gio set /headless/Desktop/btop.desktop "metadata::trusted" true