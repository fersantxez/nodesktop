#!/usr/bin/env bash

# Set current user in nss_wrapper
USER_ID=$(id -u)
GROUP_ID=$(id -g)

[[ $DEBUG == true ]] && echo "my USER_ID: $USER_ID, my GROUP_ID: $GROUP_ID"

if [ x"$USER_ID" != x"0" ]; then

    NSS_WRAPPER_PASSWD=/tmp/passwd
    NSS_WRAPPER_GROUP=/etc/group

    cat /etc/passwd > $NSS_WRAPPER_PASSWD

    #not needed with the useradd in Dockerfile
    #echo "default:x:${USER_ID}:${GROUP_ID}:Default Application User:${HOME}:/bin/bash" >> $NSS_WRAPPER_PASSWD

    export NSS_WRAPPER_PASSWD
    export NSS_WRAPPER_GROUP

    if [ -r /usr/lib/libnss_wrapper.so ]; then
        LD_PRELOAD=/usr/lib/libnss_wrapper.so
    elif [ -r /usr/lib64/libnss_wrapper.so ]; then
        LD_PRELOAD=/usr/lib64/libnss_wrapper.so
    elif [ -r /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
        LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    else
        echo "no libnss_wrapper.so installed!"
        exit 1
    fi
    #DEBUG: echo "nss_wrapper location: $LD_PRELOAD"
    export LD_PRELOAD

fi
