#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Evince Document Viewer"

sudo apt-get install -y evince
