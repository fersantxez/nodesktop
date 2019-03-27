#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget curl net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    iputils-* transmission htop locales software-properties-common dirmngr python-numpy xscreensaver arandr \
    gigolo gvfs-fuse gvfs-backends
apt-get clean -y

### Hide userland threads for HTop
echo "hide_userland_threads=1" >> /headless/.htoprc

### Gotop
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
bash /tmp/gotop/scripts/download.sh
sudo mv -f /headless/gotop /usr/bin/gotop
rm -rf /tmp/gotop


#Generate locales
echo "generate locales" #was en_US.UTF-8 or C.UTF-8
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
