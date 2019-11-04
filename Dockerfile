# Nodesktop: A Remote Desktop based on Debian

FROM debian:stretch-slim

MAINTAINER Fernando Sanchez <fernandosanchezmunoz@gmail.com>

## Connection ports for controlling the UI:
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $NO_VNC_PORT

#allow to enable or disable debug by running with env var DEBUG=true
#default no debug
ENV DEBUG=false

### Environment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=nopassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./xfce/ $HOME/

### Install custom fonts
RUN $INST_SCRIPTS/custom_fonts.sh

### Customize Desktop
RUN $INST_SCRIPTS/customize.sh

### Install chromium browser
RUN $INST_SCRIPTS/chromium.sh

### Install Google Drive client
RUN $INST_SCRIPTS/google-drive-ocamlfuse.sh
#RUN $INST_SCRIPTS/google-drive-sync.sh

### Install Sublime Text
RUN $INST_SCRIPTS/sublime.sh

### Install Google Cloud SDK
RUN $INST_SCRIPTS/gcloud.sh

### Install Evince document viewer
RUN $INST_SCRIPTS/evince.sh

### Install Bash-it
RUN $INST_SCRIPTS/bash_it.sh

### Install Tor
RUN $INST_SCRIPTS/tor.sh

### Generate certificate for TLS
RUN $INST_SCRIPTS/generate_certificate.sh

### configure startup
ADD ./scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME
RUN $INST_SCRIPTS/libnss_wrapper.sh

### Add myself as a user if the variable was passed, otherwise nss_wrapper
ENV NEWUSER=default
#First user ID in host OS. On Debian, Ubuntu is 1000 by default.
ENV USERID=1000     
#Modify for other host OS
ENV GROUPID=1000    
RUN groupadd -g $GROUPID $NEWUSER \
&& useradd -s /bin/bash -m -u $USERID -g $NEWUSER $NEWUSER \
&& usermod -aG sudo $NEWUSER \
&& printf "$NEWUSER ALL=(ALL:ALL) NOPASSWD:ALL\n" | tee -a /etc/sudoers >/dev/null
USER $USERID
RUN $INST_SCRIPTS/set_home_dir.sh $NEWUSER

### Clean up all packages
RUN $INST_SCRIPTS/cleanup.sh

ENTRYPOINT ${STARTUPDIR}/vnc_startup.sh --wait
