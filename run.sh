#!/usr/bin/env bash

# No-desktop pre-flight script
# Fernando Sanchez <fernandosanchezmunoz@gmail.com>

# every exit != 0 fails the script
set -e

echo -e "
           _         _   _           
 ___ ___ _| |___ ___| |_| |_ ___ ___ 
|   | . | . | -_|_ -| '_|  _| . | . |
|_|_|___|___|___|___|_,_|_| |___|  _|
                                |_|  
"

# =============================================================================
# Default values
# =============================================================================

export NAME=vnc
export IMAGE_NAME=gcr.io/nodesktop #fernandosanchez/vnc
export VNC_COL_DEPTH=24
export VNC_RESOLUTION=1280x1024
export VNC_PW=nopassword
export VNC_PORT=5901
export NOVNC_PORT=6901
export HOME_MOUNT_DIR=/mnt/home
export ROOT_MOUNT_DIR=/mnt/root

# =============================================================================
# Functions
# =============================================================================

# Prefixes output and writes to STDERR:
error() {
	echo -e "\n\nodesktop error: $@\n" >&2
}

# Checks for command presence in $PATH, errors:
check_command() {
	TESTCOMMAND=$1
	HELPTEXT=$2

	printf '%-50s' " - $TESTCOMMAND..."
	command -v $TESTCOMMAND >/dev/null 2>&1 || {
		echo "[ MISSING ]"
		error "The '$TESTCOMMAND' command was not found. $HELPTEXT"

		exit 1
	}
	echo "[ OK ]"
}

# =============================================================================
# Base sanity checking
# =============================================================================

# Check for our requisite binaries:
echo "Checking for requisite binaries..."
check_command docker "Please install Docker. Visit https://docs.docker.com/install/ for more information."

# Check if we've been called with silent, if so run defaults

#### FIXME

# Else if not silent, interactive check for \
# name, resolution, novnc port, password, privileged, root, home, minimal/full

#### FIXME

# =============================================================================
# Launch
# =============================================================================

docker run -d \
--privileged \
--name ${NAME} \
-p ${VNC_PORT}:5901 \
-p ${NOVNC_PORT}:6901 \
-v ${HOME}:${HOME_MOUNT_DIR} \
-v /:${ROOT_MOUNT_DIR} \
-v /etc/group:/etc/group:ro \
-v /etc/passwd:/etc/passwd:ro \
-v /etc/shadow:/etc/shadow:ro \
-v /etc/sudoers.d:/etc/sudoers.d:ro \
--user $(id -u):$(id -g) \
-e VNC_COL_DEPTH ${VNC_COL_DEPTH} \
-e VNC_RESOLUTION ${VNC_RESOLUTION} \
-e VNC_PW ${VNC_PW} \
${IMAGE_NAME}


