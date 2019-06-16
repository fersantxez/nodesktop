#!/usr/bin/env bash
# nodesktop configuration script


export NODESKTOP_STARTUP="/usr/bin/docker-nodesktop_on.sh"
export NODESKTOP_SERVICE="docker-nodesktop.service"
export VNC_PW="YesPlease!" #CHANGEME
export MY_UID="fersanchez" #FIXME

# Print commands as executed:
set -x

# The disk ID is set by Google when the device is attached:
STATEFILE="/etc/nodesktop-configured.state"

# If we've already run this script before, just exit:
if [ -f ${STATEFILE} ]; then
    exit
fi

# Idempotently install requisite packages:

# Due to the interesting locking behavior of /var/lib/dpkg/lock and `flock`,
# let's intercept the requested call in this function block, and perform the
# necessary waiting. dpkg might be running on newly-spawned machines as part
# of initialization protocols, so catch that case here (should run once): 
apt_catch() {
    # Rather than attempt an elaborate process inspection, simply run the
    # command until it works. If it doesn't, there's another issue:
    until [ $(apt-get $@ > /dev/null 2>&1)$? -eq 0 ]; do
        echo "Waiting for APT/DPKG lock..."
        sleep 1;
    done
}

apt_catch update
apt_catch install -qq \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt_catch update
apt-cache policy docker-ce
apt_catch install -qq \
	docker-ce

#create a startup service for the desktop docker container
#it can not launch docker directly due to obscure reasons. Needs to call an external script in /usr/bin/
tee /etc/systemd/system/${NODESKTOP_SERVICE} <<-EOF
[Unit]
Description=docker-nodesktop
After=docker.service
Requires=docker.service

[Service]
Type=forking
ExecStart=${NODESKTOP_STARTUP}

[Install]
WantedBy=multi-user.target
EOF

#create the launcher that the startup service calls
tee ${NODESKTOP_STARTUP} <<-"EOF"
#!/bin/bash

export IMAGE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/image -H "Metadata-Flavor: Google")
export NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/name -H "Metadata-Flavor: Google")
export CONTAINER=${NAME}
export VNC_COL_DEPTH=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/vnc-col-depth -H "Metadata-Flavor: Google")
export VNC_RESOLUTION=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/vnc-resolution -H "Metadata-Flavor: Google")
export VNC_PW=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/vnc-pw -H "Metadata-Flavor: Google")
export NOVNC_PORT=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/novnc-port -H "Metadata-Flavor: Google")
export HOME_MOUNT_DIR=/mnt/home
export ROOT_MOUNT_DIR=/mnt/root
export RAID_MOUNT_DIR=/mnt/RAID1

echo "** Removing previous instances of "$CONTAINER

/usr/bin/docker ps -q --filter "name=$CONTAINER" \
	| grep -q . \
	&& /usr/bin/docker stop $CONTAINER \
	&& /usr/bin/docker rm -fv $CONTAINER

echo "** Starting "$CONTAINER

/usr/bin/docker run \
--name $CONTAINER \
-d \
--privileged \
--restart=always \
-p $NOVNC_PORT:6901 \
-v /home/$MY_UID:$HOME_MOUNT_DIR \
-v /mnt/RAID1:$RAID_MOUNT_DIR \
-v /etc/group:/etc/group:ro \
-v /etc/passwd:/etc/passwd:ro \
-v /etc/shadow:/etc/shadow:ro \
-v /etc/sudoers.d:/etc/sudoers.d:ro \
-v /var/run:/var/run \
--user 1000:1000 \
-e VNC_COL_DEPTH=$VNC_COL_DEPTH \
-e VNC_RESOLUTION=$VNC_RESOLUTION \
-e VNC_PW=$VNC_PW \
$IMAGE

echo "** Started "$CONTAINER" from "$IMAGE

echo "** Started "$CONTAINER" from "$IMAGE
EOF

#mark the startup script executable
chmod 0755 ${NODESKTOP_STARTUP}

#reload systemd services
systemctl daemon-reload

#start nodesktop service
systemctl start ${NODESKTOP_SERVICE}
# Mark this script as having run successfully:
touch ${STATEFILE}
