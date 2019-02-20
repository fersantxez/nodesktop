#!/bin/bash
### every exit != 0 fails the script
set -e

### configure customization
tar xvfz $HOME/config_xfce4.tgz
#TODO: delete archive after uncompressing
