#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

#if this is the first time, launch ocamlfuse once to initialize -- this will launch browser for Oauth.
if [ ! -f $HOME/.onlyonce ]; then
    echo -e "ocamlfuse first launch - initialize without parameters"
    /usr/bin/google-drive-ocamlfuse
    exit
fi
#write state file to detect next launch
touch $HOME/.onlyonce

#otherwise launch again attaching home directory
/usr/bin/google-drive-ocamlfuse ~/GoogleDrive
