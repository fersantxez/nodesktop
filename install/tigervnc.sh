#!/usr/bin/env bash
set -e

export TIGERVNC_URI=https://dl.bintray.com/tigervnc/stable/tigervnc-1.8.0.x86_64.tar.gz

echo "Install TigerVNC server"
wget -qO-  ${TIGERVNC_URI} | tar xz --strip 1 -C /
