#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
if [[ -n $DEBUG ]]; then
    verbose="-v"
fi

for var in "$@"
do
    echo "fix permissions for: $var"
    find "$var"/ -name '*.sh' -exec chmod $verbose a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod $verbose a+x {} +
    chgrp -R 0 "$var" && chmod -R $verbose a+rw "$var" && find "$var" -type d -exec chmod $verbose a+x {} +
done

#Consider this for install/cleanup.sh as root (this is executed as the user)
#make the default user a sudoer
#printf 'default ALL=(ALL:ALL) NOPASSWD: ALL\n' | tee -a /etc/sudoers >/dev/null
#echo -e "**DEBUG: content of /etc/sudoers is:\n"
#cat /etc/sudoers
