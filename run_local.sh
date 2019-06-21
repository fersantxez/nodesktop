#!/usr/bin/env bash

# No-desktop pre-flight script
# Fernando Sanchez <fernandosanchezmunoz@gmail.com>

# every exit != 0 fails the script
set -e

# =============================================================================
# Default values
# =============================================================================

export NAME=nodesktop
export IMAGE_NAME=fernandosanchez/nodesktop
export VNC_COL_DEPTH=24
export VNC_RESOLUTION=1280x1024
#export VNC_PW=nopassword
export VNC_PORT=5901
export NOVNC_PORT=6901
export HOME_MOUNT_DIR=/mnt/home
export ROOT_MOUNT_DIR=/mnt/root
export SILENT=false
export MINIMAL=false

# =============================================================================
# Pretty colours
# =============================================================================

RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# =============================================================================
# Functions
# =============================================================================

# Prefixes output and writes to STDERR:
error() {
	echo -e "\n\n${RED}nodesktop error${NC}: $@\n" >&2
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
# Banner
# =============================================================================

echo -e "${BLUE}
           _         _   _           
 ___ ___ _| |___ ___| |_| |_ ___ ___ 
|   | . | . | -_|_ -| '_|  _| . | . |
|_|_|___|___|___|___|_,_|_| |___|  _|
                                |_|  
${NC}"

# =============================================================================
# Base sanity checking
# =============================================================================

# Check for our requisite binaries:
echo "Checking for requisite binaries..."
check_command docker "Please install Docker. Visit https://docs.docker.com/install/ for more information."

# =============================================================================
# FIXME: Usage
# =============================================================================

# =============================================================================
# Get Name
# =============================================================================

#first argument is the name
if [ $# -le 0 ]
  then
    read -p "** Enter a name for the instance: " $NAME
else
  export VNC_PW=$1
fi

# =============================================================================
# Get Password
# =============================================================================

#second argument is the password
if [ $# -le 1 ]
  then
    read -p "** Enter a password for the NoVNC session: " $VNC_PW
else
  export VNC_PW=$2
fi

echo "*** Starting instance "$NAME" with password "$VNC_PW

# =============================================================================
# Run with selected arguments
# =============================================================================
declare -a VARS=( \
"NAME" \
"IMAGE_NAME" \
"VNC_COL_DEPTH" \
"VNC_RESOLUTION" \
"VNC_PW" \
"VNC_PORT" \
"NOVNC_PORT" \
"HOME_MOUNT_DIR" \
"ROOT_MOUNT_DIR" \
"SILENT" \
"MINIMAL"
)

for var in "${VARS[@]}"; do
    while [ -z "${!var}" ]; do 
        echo "**ERROR: "$var" is unset or empty."
        read -r -p "**INFO: Please enter a value for "$var" : " $var
    done
    echo "**DEBUG: "$var" is set to "${!var}
done

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
-e VNC_COL_DEPTH=${VNC_COL_DEPTH} \
-e VNC_RESOLUTION=${VNC_RESOLUTION} \
-e VNC_PW=${VNC_PW} \
${IMAGE_NAME}


