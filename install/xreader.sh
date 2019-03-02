#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Xreader document viewer"

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
libjs-mathjax

mkdir xreader
cd xreader

wget \
http://packages.linuxmint.com/pool/backport/x/xreader/gir1.2-xreader_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderdocument3-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderdocument3_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview-dev_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview3-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/libxreaderview3_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader-common_1.2.2%2bserena_all.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader-dbg_1.2.2%2bserena_amd64.deb \
http://packages.linuxmint.com/pool/backport/x/xreader/xreader_1.2.2%2bserena_amd64.deb \



