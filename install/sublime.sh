#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u

echo "Install Sublime Text"

sudo apt-get install apt-transport-https

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update -y

sudo apt-get install -y sublime-text && \
mkdir -p /headless/.config/sublime-text-3/Packages/User/Dank_Neon && \
cd /headless/.config/sublime-text-3/Packages/User/Dank_Neon && \
wget https://raw.githubusercontent.com/DankNeon/sublime/master/Dank_Neon.tmTheme && \
echo '{
        "color_scheme": "Packages/User/Dank_Neon/Dank_Neon.tmTheme",
        "theme": "Adaptive.sublime-theme"
}
' > /headless/.config/sublime-text-3/Packages/User/Preferences.sublime-settings

#Desktop icon
cat <<EOF > /headless/Desktop/sublime.desktop 
[Desktop Entry]
Version=1.0
Type=Application
Name=Sublime Text
Comment=Sophisticated text editor for code, markup and prose
Exec=/opt/sublime_text/sublime_text %F
Terminal=false
MimeType=text/plain;
Icon=sublime-text
Categories=TextEditor;Development;
StartupNotify=true
Actions=Window;Document;

[Desktop Action Window]
Name=New Window
Exec=/opt/sublime_text/sublime_text -n
OnlyShowIn=Unity;

[Desktop Action Window]
Name=New File
Exec=/opt/sublime_text/sublime_text --command new_file
OnlyShowIn=Unity;
EOF
#Executable and trusted
chmod a+x /headless/Desktop/sublime.desktop
gio set /headless/Desktop/sublime.desktop "metadata::trusted" yes

