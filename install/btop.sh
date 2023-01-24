#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install btop (Bashtop C++)"

wget https://github.com/aristocratos/btop/releases/download/v1.2.13/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
mv btop/bin/btop /usr/btop
rm -Rf btop*

cat <<EOF >> /headless/Desktop/btop.desktop 
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
