#!/usr/bin/env bash

# Customize / fix home directory including permissions

# requires sudoer

#make the default user a sudoer
#printf 'default ALL=(ALL:ALL) NOPASSWD: ALL\n' | tee -a /etc/sudoers >/dev/null
#echo -e "**DEBUG: content of /etc/sudoers is:\n"
#cat /etc/sudoers

#create HOME dir and give permissions (for xscreensaver and general app prefs)
#NEWUSER=default
#mkdir -p /home/$NEWUSER 2>&1
#chown $NEWUSER /home/$NEWUSER 2>&1
#chmod 777 /home/$NEWUSER 2>&1
#export HOME=/home/$NEWUSER

#TODO: run this only if the container is running as privileged
#link /home/$USER with /headless
if [[ $DEBUG == true ]]; then
 echo -e "Link /headless with /home/${USER}\n..."
fi
USER=$(whoami)
sudo ln -s /headless /home/${USER}
sudo chown ${USER}:${USER} /home/${USER}