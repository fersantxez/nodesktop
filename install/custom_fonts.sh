#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Installing fonts"
apt-get install -y ttf-wqy-zenhei fonts-inconsolata fonts-lato fonts-cantarell git

wget http://mirrors.kernel.org/ubuntu/pool/main/u/ubuntu-font-family-sources/ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb && \
dpkg -i ./ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb && \
rm -f ./ttf-ubuntu-font-family_0.83-0ubuntu2_all.deb


echo "Installing Google fonts"
#https://gist.github.com/keeferrourke/d29bf364bd292c78cf774a5c37a791db

# dependancies: fonts-cantarell, ttf-ubuntu-font-family, git
srcdir="/tmp/google-fonts"
pkgdir="/usr/share/fonts/truetype/google-fonts"
giturl="git://github.com/google/fonts.git"

mkdir $srcdir
cd $srcdir
echo "Cloning Git repository..."
git clone $giturl

echo "Installing fonts..."
sudo mkdir -p $pkgdir
sudo find $srcdir -type f -name "*.ttf" -exec install -Dm644 {} $pkgdir \;

echo "Cleaning up..."
sudo find $pkgdir -type f -name "Cantarell-*.tff" -delete \;
sudo find $pkgdir -type f -name "Ubuntu-*.tff" -delete \;

# provides roboto
sudo apt-get --purge remove fonts-roboto

echo "Updating font-cache..."
sudo fc-cache -f > /dev/null
