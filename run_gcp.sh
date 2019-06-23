#!/usr/bin/env bash

# No-desktop GCP launcher script
# Fernando Sanchez <fernandosanchezmunoz@gmail.com>

# every exit != 0 fails the script
set -e

# =============================================================================
# Default values
# =============================================================================

#Parameters that do NOT have a default value and have to be entered in CLI necessarily
#export NAME=nodesktop
#export VNC_PW=nopassword
## Parameters that have a default value
export MACHINE_TYPE=n1-standard-2
#first debian image e.g. debian-9-drawfork-v20181101
export IMAGE_PROJECT=debian-cloud
export IMAGE_STRING="debian-9"
export BOOT_DISK_SIZE=100GB
export DOCKER_IMAGE="fernandosanchez/nodesktop:latest"
export VNC_COL_DEPTH=24
export VNC_RESOLUTION=1280x1024
export HOME_MOUNT_DIR=/mnt/home
export ROOT_MOUNT_DIR=/mnt/root
export NOVNC_PORT=6901
#parameters that are fixed
export NOVNC_TAG=novnc-server

#derived vars are exported after argument parsing
#export IMAGE=$(gcloud compute images list|grep ${IMAGE_STRING}|head -n 1|awk -s {'print $1'})

# =============================================================================
# pretty colours
# =============================================================================

RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}
           _         _   _           
 ___ ___ _| |___ ___| |_| |_ ___ ___ 
|   | . | . | -_|_ -| '_|  _| . | . |
|_|_|___|___|___|___|_,_|_| |___|  _|
                                |_|  
${NC}"

# =============================================================================
# Functions
# =============================================================================

display_usage() { 
    echo "usage: nodesktop -n name -w password [-p novnc_port] [-m machine_type] [-i image_string] [-s boot_disk_size] [-k docker_image] [-d color_depth] [-r resolution] [-H home_mount_dir][-R root_mount_dir] "
    echo "  -n, --name 				NAME 			-name of this nodesktop instance"
    echo "  -w, --password 			mypassword 		-Password to log into this server"
    echo "  -p, --port 				6901 			-TCP port to listen on for noVNC connections"
    echo "  -m, --machine_type 		n1-standard-2 	-GCE machine type"
    echo "  -i, --image_string 		debian-9 		-String to find VM image to use in catalog"
    echo "  -s, --boot_disk_size 	100GB 			-Boot disk size"
    echo "  -k, --docker_image 		fernandosanchez/nodesktop:latest"
    echo "  -d, --color_depth 		24				-Color depth for noVNC desktop"
    echo "  -r, --resolution 		1280x1024		-Resolutionfor noVNC desktop"
    echo "  -H, --home_mount_dir 	/mnt/home		-Mount point for the home directory in host"
    echo "  -R, --root_mount_dir 	/mnt/root		-Mount point for the root directory in host"
    exit 1
	} 

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
		echo "${RED}[ MISSING ]${NC}"
		error "The '$TESTCOMMAND' command was not found. $HELPTEXT"
		exit 1
	}
	echo "[ OK ]"
}

# Tests variables for valid values:
check_config() {
	PARAM=$1
	VAR=$2
	printf '%-50s' " - '$VAR'..."
	if [[ $PARAM == *"(unset)"* ]]; then
		echo "[ UNSET ]"
		error "Please set the gcloud variable '$VAR' via:
		gcloud config set $VAR <value>"

		exit 1
	fi
	echo "[ OK ]"
}

# Returns just the value we're looking for OR unset:
gcloud_activeconfig_intercept() {
	gcloud $@ 2>&1 | grep -v "active configuration"
}

# Enables a single API:
enable_api() {
	gcloud services enable $1 >/dev/null 2>&1
	if [ ! $? -eq 0 ]; then
		error "cannot enable $1. Please make sure you have privileges to enable this API"
		exit 1
	fi
}

# Enable a firewall rule for a tag/port:
enable_firewall_for_tag() {
	TESTTAG=$1
	TESTPORT=$2

	printf '%-50s' " - $TESTTAG..."
	
	if [[ ! $(gcloud compute firewall-rules list --format=json|grep $TESTTAG) ]];then
		echo -e "[CLOSED]"
		printf "Opening firewall port for "$TESTTAG" ..."

		gcloud compute firewall-rules create  \
			$TESTTAG \
			--direction=INGRESS \
			--priority=1000 \
			--network=default \
			--action=ALLOW \
			--rules=tcp:$TESTPORT \
			--source-ranges=0.0.0.0/0 \
			--target-tags=$TESTTAG \
			> /dev/null 2>&1
		if [ ! $? -eq 0 ]; then
			error "Error opening port "$TESTPORT" for tag "$TESTTAG". Please check your privileges."
			exit 1
		fi
	else
		echo -e "[OPEN]"
	fi
}

# =============================================================================
# Argument parsing
# =============================================================================

for i in "$@"
do
case $i in
    -n=*|--name=*)
    NAME="${i#*=}"
    shift # past argument=value
    ;;
    -w=*|--password=*)
    HOST="${i#*=}"
    #FIXME: ensure host is ip address or reachable hostname
    shift # past argument=value
    ;;
    -p=*|--port=*)
    PORT="${i#*=}"
    shift # past argument=value
    ;;
    -m=*|--machine-type=*)
    MACHINE_TYPE="${i#*=}"
    #FIXME: ensure machine type is valid
    shift # past argument=value
    ;;
    -i=*|--image_string=*)
    IMAGE_STRING="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--boot_disk_size=*)
    BOOT_DISK_SIZE="${i#*=}"
    shift # past argument=value
    ;;
    -k=*|--docker_image=*)
    DOCKER_IMAGE="${i#*=}"
    shift # past argument=value
    ;;
    -d=*|--color_depth=*)
    VNC_COL_DEPTH="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--resolution=*)
    VNC_RESOLUTION="${i#*=}"
    shift # past argument=value
    ;;
    -H=*|--home_mount_dir=*)
    HOME_MOUNT_DIR="${i#*=}"
    shift # past argument=value
    ;;
    -R=*|--root_mount_dir=*)
    HOME_MOUNT_DIR="${i#*=}"
    shift # past argument=value
    ;;
    *)
    # unknown option
    display_usage
    ;;
esac
done


# =============================================================================
# Argument check and correction
# =============================================================================

#Ensure all parameters are defined or ask for them interactively
# List of requisite parameters:
REQUIRED_PARAMS="
	NAME
	PASSWORD
"

for PARAM in $REQUIRED_PARAMS; do
	if [ -z "$PARAM" ]; then
		# It's already defined:
		printf '%-50s' " - $PARAM is "$(echo $PARAM)
		echo "[ ON ]"
	else
		# It needs to be defined:
		printf '%-50s' " + $PARAM"
		echo "[ OFF ]"
		#assing a value for each $PARAM
		read -p "** Enter a value for ${PARAM}: " ${PARAM}
	fi
done

#NAME
while [ $(echo ${NAME} | awk '{print length}') -ge 7 ]; do 
	echo -e "** ERROR: NAME should be 6 characters long or less"
	read -p "** Enter a new value for NAME: " NAME
done

#SHARE_PATH
echo -e "** DEBUG: share path first char is: "${SHARE_PATH:0:1}
while [ ${SHARE_PATH:0:1} != "/" ]; do 
	echo -e "** ERROR: SHARE_PATH must be a valid path in the remote server starting with /"
	read -p "** Enter a new value for SHARE_PATH: " SHARE_PATH
done
echo -e "** DEBUG: share path first char is: "${SHARE_PATH:0:1}

#TODO: check remaining parameteres. e.g. make sure remote server is valid and reachable

#DEBUG
echo "NAME        		= ${NAME}"
echo "PASSWORD    		= ${PASSWORD}"
echo "IMAGE_PROJECT		= ${IMAGE_PROJECT}"
echo "IMAGE_STRING		= ${IMAGE_STRING}"
echo "BOOT_DISK_SIZE	= ${BOOT_DISK_SIZE}"
echo "DOCKER_IMAGE		= ${DOCKER_IMAGE}"
echo "VNC_COL_DEPTH		= ${VNC_COL_DEPTH}"
echo "VNC_RESOLUTION	= ${VNC_RESOLUTION}"
echo "HOME_MOUNT_DIR	= ${HOME_MOUNT_DIR}"
echo "ROOT_MOUNT_DIR	= ${ROOT_MOUNT_DIR}"
echo "NOVNC_PORT		= ${NOVNC_PORT}"

echo -e "*** Starting instance "${BLUE}${NAME}${NC}" with password "${RED}${VNC_PW}${NC}

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

# =============================================================================
# Derived vars
# =============================================================================

export IMAGE=$(gcloud compute images list|grep ${IMAGE_STRING}|head -n 1|awk -s {'print $1'})


# =============================================================================
# Base sanity checking
# =============================================================================

# Check for our requisite binaries:
echo -e "** Checking for requisite binaries..."
check_command gcloud "** Please install the Google Cloud SDK from: https://cloud.google.com/sdk/downloads"

# This executes all the gcloud commands in parallel and then assigns them to separate variables:
# Needed for non-array capabale bashes, and for speed.
echo -e "** Checking gcloud variables..."
PARAMS=$(cat <(gcloud_activeconfig_intercept config get-value compute/zone) \
	<(gcloud_activeconfig_intercept config get-value compute/region) \
	<(gcloud_activeconfig_intercept config get-value project) \
	<(gcloud_activeconfig_intercept auth application-default print-access-token))
read GCP_ZONE GCP_REGION GCP_PROJECT GCP_AUTHTOKEN <<<$(echo $PARAMS)

# Check for our requisiste gcloud parameters:
check_config $GCP_PROJECT "project"
check_config $GCP_REGION "compute/region"
check_config $GCP_ZONE "compute/zone"

# Check credentials are set:
printf '%-50s' " - 'application-default access token'..."
if [[ $GCP_AUTHTOKEN == *"ERROR"* ]]; then
	echo "[ UNSET ]"
	error "You do not have application-default credentials set, please run this command:
	gcloud auth application-default login"
	exit 1
fi
echo "[ OK ]"

# =============================================================================
# Initialization and idempotent test/setting
# =============================================================================

# List of requisite APIs:
REQUIRED_APIS="
	compute
	dns
	storage-api
	storage-component
"

# Bulk parallel process all of the API enablement:
echo -e "** Checking requisiste GCP APIs..."

# Read-in our currently enabled APIs, less the googleapis.com part:
GCP_CURRENT_APIS=$(gcloud services list | grep -v NAME | cut -f1 -d'.')

# Keep track of whether we modified the API state for friendliness:
ENABLED_ANY=1

for REQUIRED_API in $REQUIRED_APIS; do
	if [ $(grep -q $REQUIRED_API <(echo $GCP_CURRENT_APIS))$? -eq 0 ]; then
		# It's already enabled:
		printf '%-50s' " - $REQUIRED_API"
		echo "[ ON ]"
	else
		# It needs to be enabled:
		printf '%-50s' " + $REQUIRED_API"
		enable_api $REQUIRED_API.googleapis.com &
		ENABLED_ANY=0
		echo "[ OFF ]"
	fi
done

# If we've enabeld any API, wait for child processes to finish:
if [ $ENABLED_ANY -eq 0 ]; then
	printf '%-50s' "**  Concurrently enabling APIs..."
	wait

else
	printf '%-50s' "** API status..."
fi
echo "[ OK ]"

# =============================================================================
# Open firewall ports
# =============================================================================

echo -e "** Checking for firewall ports..."
enable_firewall_for_tag ${NOVNC_TAG} ${NOVNC_PORT}

# =============================================================================
# Launch instance with container
# =============================================================================

echo -e "** Creating instance..."

gcloud beta compute instances \
	create ${NAME} \
	--machine-type=${MACHINE_TYPE} \
	--subnet=default \
	--image=${IMAGE} \
	--image-project=${IMAGE_PROJECT} \
	--boot-disk-size=${BOOT_DISK_SIZE} \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=${NAME} \
	--tags=${NOVNC_TAG} \
	--metadata-from-file startup-script=startup.sh \
	--metadata \
image=${DOCKER_IMAGE},\
name=${NAME},\
vnc-col-depth=${VNC_COL_DEPTH},\
vnc-resolution=${VNC_RESOLUTION},\
vnc-pw=${VNC_PW},\
novnc-port=${NOVNC_PORT}
	> /dev/null 2>&1
	if [ ! $? -eq 0 ]; then
		error "Error creating instance "$NAME". Please check your privileges."
		exit 1
	fi

# Show info message with URL
export EXT_IP=$(gcloud compute instances list | grep ${NAME} | awk '{print $5}')
echo -e "** ${BLUE}Success!${NC} nodesktop will be available shortly at:"
echo -e "${BLUE}http://"${EXT_IP}":"${NOVNC_PORT}${NC}
