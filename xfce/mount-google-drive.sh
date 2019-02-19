#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

export GDRIVE_MOUNT_DIR=~/GoogleDrive

#make directory to mount
mkdir -p $GDRIVE_MOUNT_DIR
chmod 777 $GDRIVE_MOUNT_DIR

#launch ocamlfuse once to initialize -- this will launch browser for Oauth.
#sleep 3
#launch again attaching home directory
/usr/bin/google-drive-ocamlfuse && \
sleep 10 && \
/usr/bin/google-drive-ocamlfuse $GDRIVE_MOUNT_DIR
