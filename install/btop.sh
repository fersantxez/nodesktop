#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install btop (Bashtop C++)"

wget https://github.com/aristocratos/btop/releases/download/v1.3.2/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
mv btop/bin/btop /usr/bin/btop
rm -Rf btop*

#Desktop icon
f=/headless/Desktop/btop.desktop 
cat <<EOF > $f
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
chmod 755 $f
dbus-launch gio set $f "metadata::trusted" true
dbus-launch gio set -t string $f "metadata::xfce-exe-checksum" "$(sha256sum $f | awk '{print $1}')"