#!/usr/bin/env bash
#generate self certificate

set -e

export COUNTRY="US"
export STATE="NY"
export LOCATION="New York"
export ORGANIZATION="nodesktop"
export OU="nodesktop"
export CN="nodesktop.org"

export CERT=${NO_VNC_HOME}/self.pem
export PRIV_KEY=key.pem
export DURATION_DAYS=365

#openssl req -nodes -newkey rsa:2048 -keyout private.key -out CSR.csr -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=ssl.raymii.org"
#openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
openssl req \
-x509 \
-newkey rsa:4096 \
-keyout ${PRIV_KEY} \
-out ${CERT} \
-days ${DURATION_DAYS} \
-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${OU}/CN=${CN}"

#copy to ${HOME}
cp ${CERT} ${HOME}