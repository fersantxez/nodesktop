#!/usr/bin/env bash

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
gio set /home/${USER}/Desktop/*.desktop "metadata::trusted" yes