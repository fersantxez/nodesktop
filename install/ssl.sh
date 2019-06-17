#!/usr/bin/env bash
#generate self certificate

set -e

export CERT=self.pem
export PRIV_KEY=key.pem
export DURATION_DAYS=365
export COUNTRY="US"
export STATE="NY"
export LOCATION="New York"
export ORGANIZATION="nodesktop"
export OU="nodesktop"
export CN="nodesktop.org"

openssl req \
-nodes \
-x509 \
-newkey rsa:4096 \
-keyout ${PRIV_KEY} \
-out ${CERT} \
-days ${DURATION_DAYS} \
-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${OU}/CN=${CN}"
