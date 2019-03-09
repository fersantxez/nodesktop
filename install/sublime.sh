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
echo "{
        "color_scheme": "Packages/User/Dank_Neon/Dank_Neon.tmTheme"
}
" > /headless/.config/sublime-text-3/Packages/User/Preferences.sublime-settings