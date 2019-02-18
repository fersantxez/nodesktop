#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Ocamlfuse"

add-apt-repository ppa:alessandro-strada/ppa

apt-get update

apt-get install google-drive-ocamlfuse