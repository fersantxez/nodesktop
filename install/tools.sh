#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget net-tools locales bzip2 git sudo gnupg-agent openssh-client openssh-server \
    htop locales software-properties-common dirmngr python-numpy #used for websockify/novnc
apt-get clean -y

#Generate locales
echo "generate locales" #was en_US.UTF-8 or C.UTF-8
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

### Add myself as a user if the variable was passed, otherwise nss_wrapper
if [ -z ${NEWUSER+x} ]; then
    echo -e "Adding new user and group: "${NEWUSER}
    groupadd -g 5001 $NEWUSER
    useradd -s /bin/bash -m -u 5001 -g $NEWUSER $NEWUSER
fi
