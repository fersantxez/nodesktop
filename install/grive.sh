#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Grive"

apt-get install --yes --no-install-recommends \
  libbinutils libboost-filesystem1.67.0 libboost-program-options1.67.0 \
  libboost-regex1.67.0 libboost-system1.67.0 libcurl4 libgcrypt20 libyajl2 \
  grive
  rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

mkdir -p /mnt/data

cd /mnt/data

/usr/local/bin/dumb-init /usr/local/bin/grive