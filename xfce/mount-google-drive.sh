#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

#launch ocamlfuse once to initialize -- this will launch browser for Oauth.
#sleep 3
#launch again attaching home directory
/usr/bin/google-drive-ocamlfuse && \
sleep 10 && \
/usr/bin/google-drive-ocamlfuse $GDRIVE_MOUNT_DIR
