#!/bin/bash
### every exit != 0 fails the script
set -e

### configure customization
tar xvfz $HOME/config_xfce4.tgz && \
cp -R $HOME/.config /etc/skel && \
rm -f $HOME/config_xfce4.tgz
### put under /etc/skel to turn into default config and avoid "first start"

### renaming and moving /etc/xdg/xfce4/panel/default.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml will remove the prompt and use that file to create the default panel layout.
mv -f /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml && \
rm -f $HOME/.config/xfce4/panel/default.xml 


### Install GTK theme
echo "Install Gnome Arc Theme"
#https://github.com/horst3180/arc-theme

wget https://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/all/arc-theme_1488477732.766ae1a-0_all.deb
dpkg -i arc-theme_1488477732.766ae1a-0_all.deb && \
rm -f arc-theme_1488477732.766ae1a-0_all.deb

