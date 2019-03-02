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
apt-get install -y gtk2-engines-murrine
wget https://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/all/arc-theme_1488477732.766ae1a-0_all.deb
dpkg -i arc-theme_1488477732.766ae1a-0_all.deb && \
rm -f $HOME/arc-theme_1488477732.766ae1a-0_all.deb

### Install Moka Icons
echo "Install Faba Icons"
wget http://ftp.br.debian.org/debian/pool/main/f/faba-icon-theme/faba-icon-theme_4.1.2-1_all.deb && \
dpkg -i faba-icon-theme_4.1.2-1_all.deb
echo "Install Moka Icons"
wget http://ftp.br.debian.org/debian/pool/main/m/moka-icon-theme/moka-icon-theme_5.3.5-1_all.deb && \
dpkg -i $HOME/moka-icon-theme_5.3.5-1_all.deb

