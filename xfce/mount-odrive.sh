#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

odrive=/headless/.odrive-agent/bin/odrive
KEY_PATH=/headless/.odrive-agent/.ak
MOUNT_PATH=/headless/odrive-mount/

if [ ! -f ${KEY_PATH} ]; then
    xterm -e "echo -e 'Odrive first launch - initializing \n
    Please enter your Auth Key. If you do not have one, press Enter and go to
    https://www.odrive.com/account/authcodes to get one:' && \
    read -p 'Enter Auth Key to continue or press Enter to exit: ' authkey;  \
    exit"
else
    read -p 'Odrive key found, assuming previous init. Press Enter to Exit';
fi


#Write auth key to file or exit if none
if [ -z "${authkey}" ] then
    exit;
else
    #Initialize with auth key
    echo $authkey > ${KEY_PATH}
    ${odrive} authenticate ${authkey}
    ${odrive} mount ${MOUNT_PATH}
    read -p 'Odrive successfully mounted on ${MOUNT_PATH}. Press Enter to continue';
fi


