#!/usr/bin/env bash
set -e

export TIGERVNC_URI=https://sourceforge.net/projects/tigervnc/files/stable/1.8.0/tigervnc-1.8.0.x86_64.tar.gz/download

echo "Install TigerVNC server"
wget -qO-  ${TIGERVNC_URI} | tar xz --strip 1 -C /
