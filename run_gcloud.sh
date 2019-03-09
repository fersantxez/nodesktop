#!/usr/bin/env bash

# No-desktop GCP launcher script
# Fernando Sanchez <fernandosanchezmunoz@gmail.com>

# =============================================================================
# Default values
# =============================================================================

export NAME=vnc
export PROJECT=ml-sme-training
export ZONE=us-east1-c
export MACHINE_TYPE=n1-standard-2
export SVC_ACCOUNT=537060948457-compute@developer.gserviceaccount.com
export IMAGE=cos-stable-72-11316-136-0
export IMAGE_PROJECT=cos-cloud
export BOOT_DISK_SIZE=200GB
export CONTAINER_IMAGE=fernandosanchez/vnc

# =============================================================================
# Functions
# =============================================================================

# Prefixes output and writes to STDERR:
error() {
	echo -e "\n\nNo-Desktop Error: $@\n" >&2
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
		echo -e "\n  ! - Error enabling $1"
		exit 1
	fi
}


# =============================================================================
# Base sanity checking
# =============================================================================

# Check for our requisite binaries:

echo "Checking for requisite binaries..."
check_command gcloud "Please install the Google Cloud SDK from: https://cloud.google.com/sdk/downloads"


# This executes all the gcloud commands in parallel and then assigns them to separate variables:
# Needed for non-array capabale bashes, and for speed.
echo "Checking gcloud variables..."
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
	cloudresourcemanager
	compute container
	dns
	iam
	replicapool
	replicapoolupdater
	resourceviews
	sql-component
	sqladmin
	storage-api
	storage-component
"

# Bulk parrallel process all of the API enablement:
echo "Checking requisiste GCP APIs..."

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
	printf '%-50s' " Concurrently enabling APIs..."
	wait

else
	printf '%-50s' " API status..."
fi
echo "[ OK ]"


# Launch a VM running a vnc desktop container on GCP

gcloud beta compute instances \
	create-with-container ${NAME} \
	--project=${PROJECT} \
	--zone=${ZONE} \
	--machine-type=${MACHINE_TYPE} \
	--subnet=default \
	--image=${IMAGE} \
	--image-project=${IMAGE_PROJECT} \
	--boot-disk-size=${BOOT_DISK_SIZE} \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=${NAME} \
	--container-image=${CONTAINER_IMAGE} \
	--container-restart-policy=always \
	--labels=container-vm=${IMAGE}

	#--network-tier=PREMIUM \
	#--maintenance-policy=MIGRATE \
	#--service-account=${SVC_ACCOUNT} \
	#--scopes=https://www.googleapis.com/auth/devstorage.read_only,\
#https://www.googleapis.com/auth/logging.write,\
#https://www.googleapis.com/auth/monitoring.write,\
#https://www.googleapis.com/auth/servicecontrol,\
#https://www.googleapis.com/auth/service.management.readonly,\
#https://www.googleapis.com/auth/trace.append \