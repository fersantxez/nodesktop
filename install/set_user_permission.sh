#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
if [[ -n $DEBUG ]]; then
    verbose="-v"
fi

for var in "$@"
do
    echo "fix permissions for: $var"
    find "$var"/ -name '*.sh' -exec chmod $verbose a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod $verbose a+x {} +
    chgrp -R 0 "$var" && chmod -R $verbose a+rw "$var" && find "$var" -type d -exec chmod $verbose a+x {} +
done

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
echo -e "** DEBUG: my user id (who is sudoing is): "$(whoami)
echo -e  "** DEBUG: writing cert to: ${CERT}"
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
