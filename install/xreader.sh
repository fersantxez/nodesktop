#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Xreader document viewer"

### Install from packages

## Mint backports 

mkdir xreader
cd xreader

wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu55_55.1-7_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/main/g/geoclue/libgeoclue0_0.12.99-4ubuntu1_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg8-empty/libjpeg8_8c-2ubuntu8_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.4.2-0ubuntu3_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/main/libw/libwebp/libwebp5_0.4.4-1_amd64.deb \
http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libwebkit2gtk-3.0-25_2.4.10-0ubuntu1_amd64.deb && \
sudo apt install ./*.deb && \
sudo rm -f *.deb && \
## Debian packages
sudo apt-get install -y \
libcaja-extension1 \
libnemo-extension1 \
libgail-3-0 \
libdjvulibre21 \
libgxps2 \
libkpathsea6 \
libspectre1 \
libjavascriptcoregtk-3.0-0 \
libenchant1c2a \
libfontconfig1 \
libgeoclue0 \
libharfbuzz-icu0 \
libicu55 \
libjpeg8 \
libpng12-0 \
libwebp5 \
libxslt1.1 \
libwebkitgtk-3.0-0 \
gstreamer1.0-plugins-good \
libcaja-extension1 \
libjs-mathjax \
fonts-mathjax \
fonts-mathjax-extras \
fonts-stix \
libjs-mathjax-doc && \
### app packages 
wget \
http://packages.linuxmint.com/pool/backport/x/xreader/gir1.2-xreader_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderdocument3-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderdocument3_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview-dev_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview3-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview3_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader-common_1.2.2%2bserena_all.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader_1.2.2%2bserena_amd64.deb && \
sudo apt install ./*.deb && \
sudo rm -f *.deb


### Install from source
#sudo apt install -y git dpkg-dev
#
#sudo apt install -y \
#gobject-introspection libdjvulibre-dev libgail-3-dev          \
#libgirepository1.0-dev libgtk-3-dev libgxps-dev               \
#libkpathsea-dev libpoppler-glib-dev libsecret-1-dev           \
#libspectre-dev libtiff-dev libwebkit2gtk-4.0-dev libxapp-dev  \
#mate-common meson xsltproc yelp-tools

#git clone https://github.com/linuxmint/xreader.git && \
#cd xreader && \
#meson debian/build \
#        --prefix=/usr/local \
#        --buildtype=plain \
#        -D deprecated_warnings=false \
#        -D djvu=true \
#        -D dvi=true \
#        -D t1lib=true \
#        -D pixbuf=true \
#        -D comics=true \
#        -D introspection=true && \
#ninja -C debian/build && \
#ninja -C debian/build install

