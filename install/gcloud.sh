#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u

echo "Install Google Cloud SDK"
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 
curl --insecure https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
apt-get update -y 
apt-get install google-cloud-sdk -y