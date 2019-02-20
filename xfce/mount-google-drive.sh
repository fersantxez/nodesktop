#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

#if this is the first time, launch ocamlfuse once to initialize -- this will launch browser for Oauth.
if [ ! -f $HOME/.onlyonce ]; then
    xterm -e "echo -e 'Google drive first launch - initializing'; \
    /usr/bin/google-drive-ocamlfuse; \
    read -p 'Please run again to mount the drive. Press any key to continue';  \
    exit"
fi
#write state file to detect next launch
touch $HOME/.onlyonce

#otherwise launch again attaching home directory
xterm -e "read -p 'Google drive initialized. Press any key to mount your drive in ~/GoogleDrive'; \ 
/usr/bin/google-drive-ocamlfuse ~/GoogleDrive"
