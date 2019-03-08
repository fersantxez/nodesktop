# Docker container with headless VNC/noVNC session

Forked/adapted from https://github.com/ConSol/docker-headless-vnc-container

This repository contains a Docker image with a headless VNC environment, installed with the following components:

* Desktop environment [**Xfce4**](http://www.xfce.org)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client (default http port `6901`)
* [**Google Chrome**](https://www.google.com/chrome/)
* [**OccamlFUSE for Google Drive access**](https://astrada.github.io/google-drive-ocamlfuse/)
* [**Sublime Text**](https://www.sublimetext.com/)
* [**Evince**](https://wiki.gnome.org/Apps/Evince)
* [**Bash-it**](https://github.com/Bash-it/bash-it)

## TL;DR

On a host with docker and curl available:

`source <(curl -s https://raw.githubusercontent.com/fernandosanchezmunoz/vnc/master/run.sh)`

You can connect with a browser to:

`http://[YOUR_HOST_IP]:6901`

Default password is 'vncpassword'

## Usage examples
  
- Run anonymously mounting your home directory (user appears as "default" but has permissions on your directories):

      docker run -d --name vnc -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home fernandosanchez/vnc

- Run as privileged as current user replicating the identity and password of the host system, mounting your home directory and the host root filesystem under /mnt/root

      docker run -d --privileged --name vnc -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home -v /:/mnt/root -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro --user $(id -u):$(id -g) fernandosanchez/vnc

- If you want to get into the container use interactive mode `-it` and `bash`
      
      docker run -it --name vnc -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home --user $(id -u):$(id -g) fernandosanchez/vnc /bin/bash

# Connect & Control
If the container is started like mentioned above, connect via one of these options:

* connect via __VNC viewer `localhost:5901`__, default password: `vncpassword`
* connect via __noVNC HTML5 full client__: [`http://localhost:6901/vnc.html`](http://localhost:6901/vnc.html), default password: `vncpassword` 
* connect via __noVNC HTML5 lite client__: [`http://localhost:6901/?password=vncpassword`](http://localhost:6901/?password=vncpassword) 

## Hints

### Change User of running Container

Per default, all container processes will be executed with user id `1000`. You can change the user id as follows: 

#### Using root (user id `0`)
Add the `--user` flag to your docker run command:

    docker run -it --user 0 -p 6901:6901 fernandosanchez/vnc

#### Using user and group id of host system
Add the `--user` flag to your docker run command:

    docker run -it -p 6901:6901 --user $(id -u):$(id -g) fernandosanchez/vnc

### Override VNC environment variables
The following VNC environment variables can be overwritten at the `docker run` phase to customize your desktop environment inside the container:
* `VNC_COL_DEPTH`, default: `24`
* `VNC_RESOLUTION`, default: `1280x1024`
* `VNC_PW`, default: `my-pw`

#### Example: Override the VNC password
Simply overwrite the value of the environment variable `VNC_PW`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_PW=my-pw fernandosanchez/vnc

#### Example: Override the VNC resolution
Simply overwrite the value of the environment variable `VNC_RESOLUTION`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_RESOLUTION=800x600 fernandosanchez/vnc
    
### View only VNC
It's possible to prevent unwanted control via VNC. Therefore you can set the environment variable `VNC_VIEW_ONLY=true`. If set, the startup script will create a random password for the control connection and use the value of `VNC_PW` for view only connection over the VNC connection.

     docker run -it -p 5901:5901 -p 6901:6901 -e VNC_VIEW_ONLY=true fernandosanchez/vnc

