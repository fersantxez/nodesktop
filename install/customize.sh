#!/bin/bash
### every exit != 0 fails the script
set -e

### configure customization
tar xvfz $HOME/config_xfce4.tgz
#delete archive after uncompressing
rm -f $HOME/config_xfce4.tgz