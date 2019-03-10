# Headless Desktop on a Docker container through NoVNC

This repository contains a Docker image with a headless VNC/NoVNC environment including a few handy things:

* Desktop environment [**Xfce4**](http://www.xfce.org)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client enabling access through a standard web browser 
* [**Google Chrome**](https://www.google.com/chrome/)
* [**OccamlFUSE for Google Drive access**](https://astrada.github.io/google-drive-ocamlfuse/)
* [**Sublime Text**](https://www.sublimetext.com/)
* [**Evince**](https://wiki.gnome.org/Apps/Evince)
* [**Bash-it**](https://github.com/Bash-it/bash-it)

## TL;DR

On a host with docker and curl available:

`source <(curl -s https://raw.githubusercontent.com/fernandosanchezmunoz/nodesktop/master/run_local.sh)`

You can connect with a browser to:

`http://[YOUR_HOST_IP]:6901`

Default password is 'nopassword'

## Usage examples
  
- Run anonymously mounting your home directory (user appears as "default" but has permissions on your directories):

      docker run -d --name nodesktop -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home fernandosanchez/nodesktop

- Run as privileged as current user replicating the identity and password of the host system, mounting your home directory and the host root filesystem under /mnt/root

      docker run -d --privileged --name nodesktop -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home -v /:/mnt/root -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro --user $(id -u):$(id -g) fernandosanchez/nodesktop

- If you want to get into the container use interactive mode `-it` and `bash`
      
      docker run -it --name nodesktop -p 5901:5901 -p 6901:6901 -v $HOME:/mnt/home --user $(id -u):$(id -g) fernandosanchez/nodesktop /bin/bash

## Connect & Control

* connect with __any web browser__: [`http://YOUR_HOST:6901`](http://localhost:6901), default password: `nopassword` 
* or with a __VNC viewer__: [`YOUR_HOST:5901`](http://localhost:5901), default password: `nopassword`

## Hints

### Change User of running Container

Per default, all container processes will be executed with user id `1000`. You can change the user id as follows: 

#### Using root (user id `0`)
Add the `--user` flag to your docker run command:

    docker run -it --user 0 -p 6901:6901 fernandosanchez/nodesktop

#### Using user and group id of host system
Add the `--user` flag to your docker run command:

    docker run -it -p 6901:6901 --user $(id -u):$(id -g) fernandosanchez/nodesktop

### Override VNC environment variables
The following VNC environment variables can be overwritten at the `docker run` phase to customize your desktop environment inside the container:
* `VNC_COL_DEPTH`, default: `24`
* `VNC_RESOLUTION`, default: `1280x1024`
* `VNC_PW`, default: `my-pw`

#### Example: Override the VNC password
Simply overwrite the value of the environment variable `VNC_PW`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_PW=my-pw fernandosanchez/nodesktop

#### Example: Override the VNC resolution
Simply overwrite the value of the environment variable `VNC_RESOLUTION`. For example in
the docker run command:

    docker run -it -p 5901:5901 -p 6901:6901 -e VNC_RESOLUTION=800x600 fernandosanchez/nodesktop
    
### View only VNC
It's possible to prevent unwanted control via VNC. Therefore you can set the environment variable `VNC_VIEW_ONLY=true`. If set, the startup script will create a random password for the control connection and use the value of `VNC_PW` for view only connection over the VNC connection.

     docker run -it -p 5901:5901 -p 6901:6901 -e VNC_VIEW_ONLY=true fernandosanchez/nodesktop
     
### Credits

This was largely forked/adapted from https://github.com/ConSol/docker-headless-vnc-container

