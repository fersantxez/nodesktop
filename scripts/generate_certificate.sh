#!/usr/bin/env bash

#Generate Certificates for HTTPS
echo -e "\n------------------ Generate Certificate ----------------------------"
#TEST DEBUG
export CERT=${NO_VNC_HOME}/self.pem
export PRIV_KEY=${NO_VNC_HOME}/self.pem
export DURATION_DAYS=365
export COUNTRY="US"
export STATE="NY"
export LOCATION="New York"
export ORGANIZATION="nodesktop"
export OU="nodesktop"
export CN="nodesktop.org"

if [[ $DEBUG == true ]]; then
echo -e  "** DEBUG: writing cert to: ${CERT}"
echo -e "** DEBUG: my user id (who is sudoing is): "$(whoami)
fi

#Remove sudo lecture - otherwise it annoys on non-interactive
echo 'Defaults lecture="never"' >> /etc/sudoers

#FIXME: these sudo fail
chmod 777 ${NO_VNC_HOME} && \
rm -f $CERT && \
openssl req \
-new \
-x509 \
-days ${DURATION_DAYS} \
-nodes \
-out ${CERT} \
-keyout ${PRIV_KEY} \
-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${OU}/CN=${CN}" && \
chmod 0644 ${CERT}

