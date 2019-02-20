#!/bin/bash
### every exit != 0 fails the script
set -e

### configure customization
#tar xvfz $HOME/config_xfce4.tgz && \
#cp -R $HOME/.config /etc/skel && \
#rm -f $HOME/config_xfce4.tgz
### put under /etc/skel to turn into default config and avoid "first start"

### renaming and moving /etc/xdg/xfce4/panel/default.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml will remove the prompt and use that file to create the default panel layout.
mv -f /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
rm -f $HOME/.config/xfce4/panel/default.xml 

