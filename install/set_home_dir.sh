#!/usr/bin/env bash

set -x

# Customize / fix home directory including permissions

USER=$1

#link /home/$USER with /headless
if [[ $DEBUG == true ]]; then
 echo -e "Link /headless with /home/${USER}\n..."
fi

ln -s /headless /home/${USER}
chown ${USER}:${USER} /home/${USER}

export SHELL=/usr/bin/bash

#mark all desktop shortcuts as executable
for file in /headless/Desktop/*.desktop; do
  sudo chmod a+x $file
  sudo chown ${USER}:${USER} $file
  sudo /usr/bin/gio set $file "metadata::trusted" yes
done