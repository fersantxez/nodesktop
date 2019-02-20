#!/bin/bash
### every exit != 0 fails the script
set -e

### configure customization
tar xvfz $HOME/config_xfce4.tgz && \
cp -R $HOME/.config /etc/skel && \
rm -f $HOME/config_xfce4.tgz
### put under /etc/skel to turn into default config and avoid "first start"

