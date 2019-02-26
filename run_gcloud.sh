#!/usr/bin/env bash

#launch a VM running a vnc desktop container on GCP

export NAME=vnc
export PROJECT=ml-sme-training
export ZONE=us-east1-c
export MACHINE_TYPE=n1-standard-2
export SVC_ACCOUNT=537060948457-compute@developer.gserviceaccount.com
export IMAGE=cos-stable-72-11316-136-0
export IMAGE_PROJECT=cos-cloud
export BOOT_DISK_SIZE=200GB
export CONTAINER_IMAGE=fernandosanchez/vnc


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