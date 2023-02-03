#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Soulseek music download client"

wget --no-check-certificate https://www.slsknet.org/SoulseekQt/Linux/SoulseekQt-2018-1-30-64bit-appimage.tgz
tar xvfz SoulseekQt-2018-1-30-64bit-appimage.tgz 
mv SoulseekQt-2018-1-30-64bit.AppImage /usr/bin/soulseek
chmod +x /usr/bin/soulseek
rm -Rf SoulseekQt-2018-1-30-64bit-appimage.tgz

cat <<EOF >> /headless/Desktop/soulseek.desktop 
[Desktop Entry]
Name=SoulseekQt
Exec=/usr/bin/soulseek
Icon=xonotic
Type=Application
Terminal=false
Comment=C++/QT3 SoulseekQt client
Categories=Qt;Network;
Name[en_US]=SoulseekQt
EOF
