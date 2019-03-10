# This Dockerfile is used to build an headless vnc image based on Debian

FROM debian:stretch-slim

MAINTAINER Fernando Sanchez <fernandosanchezmunoz@gmail.com>

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
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

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./xfce/ $HOME/

### Install custom fonts
RUN $INST_SCRIPTS/custom_fonts.sh

### Customize Desktop
RUN $INST_SCRIPTS/customize.sh

### Install chrome browser
RUN $INST_SCRIPTS/chrome.sh

### Install Google Drive client
RUN $INST_SCRIPTS/google-drive-ocamlfuse.sh

### Install Sublime Text
RUN $INST_SCRIPTS/sublime.sh

### Install Google Cloud SDK
RUN $INST_SCRIPTS/gcloud.sh

### Install Evince document viewer
RUN $INST_SCRIPTS/evince.sh

### Install Bash-it
RUN $INST_SCRIPTS/bash_it.sh

### re-fix user permissions
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Clean up all packages
RUN $INST_SCRIPTS/cleanup.sh

### Add myself as a user if the variable was passed, otherwise nss_wrapper
ENV NEWUSER=default
RUN groupadd -g 5001 $NEWUSER \
&& useradd -s /bin/bash -m -u 5001 -g $NEWUSER $NEWUSER
USER 5001

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
