#!/usr/bin/env bash

# Customize / fix home directory including permissions

#link /home/$USER with /headless
if [[ $DEBUG == true ]]; then
 echo -e "Link /headless with /home/${USER}\n..."
fi
USER=$(whoami)
sudo ln -s /headless /home/${USER}
sudo chown ${USER}:${USER} /home/${USER}