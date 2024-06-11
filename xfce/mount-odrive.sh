#!/usr/bin/env bash

odrive=/headless/.odrive-agent/bin/odrive
odriveagent=/headless/.odrive-agent/bin/odriveagent
KEY_PATH=/headless/.odrive-agent/.ak
MOUNT_PATH=/headless/odrive-mount/google-drive/
REMOTE_PATH='Google Drive/'

#Run agent in the background
pidof odriveagent > /dev/null
if [[ $? -ne 0 ]]; then
    nohup ${odriveagent} > /dev/null 2>&1 &
else
    echo "Odrive agent already running"
fi

#Check for existing key or ask for one
if [ ! -f ${KEY_PATH} ]; then
    read -p "Enter Auth Key to continue: " authkey
    echo ${authkey} > ${KEY_PATH}
else
    echo "Odrive key found, assuming previous init"
    authkey=$(<${KEY_PATH})
fi

#Write auth key to file or exit if none
if [ -z "${authkey}" ]; then
    exit
else
    #Initialize with auth key
    echo $authkey > ${KEY_PATH}
    ${odrive} authenticate ${authkey}
    mkdir -p ${MOUNT_PATH}
    ${odrive} mount "${MOUNT_PATH}" "${REMOTE_PATH}"
    read -p 'Odrive successfully mounted on '${MOUNT_PATH}'. Press Enter to continue';
fi


