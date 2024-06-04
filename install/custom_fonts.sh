#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Installing fonts"
apt-get install -y ttf-wqy-zenhei fonts-inconsolata fonts-lato fonts-cantarell git

wget http://mirrors.kernel.org/ubuntu/pool/main/u/ubuntu-font-family-sources/ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb && \
dpkg -i ./ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb && \
rm -f ./ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb

#Rbt
RBT_ID=1D_i45dmBKZDA8ZsQ_cgdMzvn9_YRKEXu
RBT_URL="https://drive.google.com/uc?export=download&id=${RBT_ID}"  
wget -O RBT.zip \
    --no-check-certificate \
    -r ${RBT_URL}
unzip RBT.zip && \
sudo mv *.ttf /usr/share/fonts/truetype && \
rm -Rf ./__MACOSX ./RBT.zip 

#echo "Installing Google fonts"
#https://gist.github.com/keeferrourke/d29bf364bd292c78cf774a5c37a791db

# dependancies: fonts-cantarell, ttf-ubuntu-font-family, git
#export srcdir="/tmp/google-fonts"
#export pkgdir="/usr/share/fonts/truetype/google-fonts"
#export giturl="git://github.com/google/fonts.git"

#mkdir $srcdir
#cd $srcdir
#echo "Cloning Git repository..."
#git clone $giturl

#echo "Installing fonts..."
#sudo mkdir -p $pkgdir
#sudo find ${srcdir} -type f -name "*.ttf" -exec install -Dm644 {} ${pkgdir} \;

#echo "Cleaning up..."
#sudo find ${pkgdir} -type f -name "Cantarell-*.tff" -exec rm -f {} \;
#sudo find ${pkgdir} -type f -name "Ubuntu-*.tff" -exec rm -f {} \;

echo "Updating font-cache..."
sudo fc-cache -f > /dev/null
