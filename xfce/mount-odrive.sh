#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

odrive=/headless/.odrive-agent/bin/odrive
odrive-agent=/headless/.odrive-agent/bin/odriveagent
KEY_PATH=/headless/.odrive-agent/.ak
MOUNT_PATH=/headless/odrive-mount/google-drive/
REMOTE_PATH="Google Drive/"

#Run agent in the background
ps -eaf | grep odriveagent
if [ $? -eq 1 ]; then
    nohup ${odrive-agent} > /dev/null 2>&1 &
else
    echo "Odrive agent already running"
fi

#Check for existing key or ask for one
if [ ! -f ${KEY_PATH} ]; then
    xfce4-terminal -e "echo -e 'Odrive first launch - initializing \n
    Please enter your Auth Key. If you do not have one, press Enter and go to
    https://www.odrive.com/account/authcodes to get one:' && \
    read -p 'Enter Auth Key to continue or press Enter to exit: ' authkey;  \
    exit"
else
    read -p 'Odrive key found, assuming previous init. Press Enter to Exit';
    authkey=$(<${KEY_PATH})
fi

#Write auth key to file or exit if none
if [ -z "${authkey}" ] then
    exit;
else
    #Initialize with auth key
    echo $authkey > ${KEY_PATH}
    ${odrive} authenticate ${authkey}
    mkdir -p ${MOUNT_PATH}
    ${odrive} mount ${MOUNT_PATH} ${REMOTE_PATH}
    read -p 'Odrive successfully mounted on ${MOUNT_PATH}. Press Enter to continue';
fi


