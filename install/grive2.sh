#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Google Drive through Grive2"

apt-get install --yes --no-install-recommends g++ cmake build-essential \
  libgcrypt11-dev libyajl-dev libboost-all-dev \
  libcurl4-openssl-dev libexpat1-dev libcppunit-dev \
  binutils-dev pkg-config zlib1g-dev && \
  rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 
mv dumb-init_1.2.1_amd64 /usr/local/bin/dumb-init
chmod +x /usr/local/bin/dumb-init

git clone https://github.com/vitalif/grive2

cd /grive2 && \
  mkdir build && \
  cd build && \
  cmake .. && \
  make -j4 && \
  mv /grive2/build/grive/grive /usr/local/bin/grive && \
  rm -rf /grive2

mkdir -p /mnt/data

cd /mnt/data

/usr/local/bin/dumb-init /usr/local/bin/grive




