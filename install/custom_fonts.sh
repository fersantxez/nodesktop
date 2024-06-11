#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Installing fonts"
apt-get install -y ttf-wqy-zenhei fonts-inconsolata fonts-lato fonts-cantarell git

#Rbt
RBT_ID=1D_i45dmBKZDA8ZsQ_cgdMzvn9_YRKEXu
RBT_URL="https://drive.google.com/uc?export=download&id=${RBT_ID}"  
wget -O RBT.zip \
    --no-check-certificate \
    -r ${RBT_URL}
unzip RBT.zip && \
sudo mv *.ttf /usr/share/fonts/truetype && \
rm -Rf ./__MACOSX ./RBT.zip 

echo "Updating font-cache..."
sudo fc-cache -f > /dev/null
