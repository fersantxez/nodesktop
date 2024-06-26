#!/bin/bash

## print out help
help (){
echo "
USAGE:
docker run -it -p 6901:6901 -p 5901:5901 fernandosanchez/nodesktop:<tag> <option>

TAGS:
latest  stable version of branch 'master'
dev     current development version of branch 'dev'

OPTIONS:
-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received
-s, --skip      skip the vnc startup and just execute the assigned command.
                example: docker run consol/centos-xfce-vnc --skip bash
-d, --debug     enables more detailed startup output
                e.g. 'docker run consol/centos-xfce-vnc --debug bash'
-h, --help      print out this help

Fore more information see: https://github.com/fernandosanchez/nodesktop
"
}

echo -e "***START**** vnc_startup.sh with DEBUG set to:"$DEBUG


if [[ $1 =~ -h|--help ]]; then
    help
    exit 0
fi

# should also source $STARTUPDIR/generate_container_user.sh
source $HOME/.bashrc
#FIXME - hack
if [[ -f $STARTUPDIR"/generate_container_user.sh" ]]; then
    source $STARTUPDIR/generate_container_user.sh
fi

# add `--skip` to startup args, to skip the VNC startup procedure
if [[ $1 =~ -s|--skip ]]; then
    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi

if [[ $1 =~ -d|--debug ]]; then
    echo -e "\n\n------------------ DEBUG VNC STARTUP -----------------"
    export DEBUG=true
fi

# DEBUG = echo/log commands as executed, otherwise every exit != 0 fails the script
[[ $DEBUG == true ]] && set -x || set -e 

## correct forwarding of shutdown signal
cleanup () {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

## resolve_vnc_connection
VNC_IP=$(hostname -i)

## change vnc password
echo -e "\n------------------ change VNC password  ------------------"

# first entry is control, second is view (if only one is valid for both)
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"

if [[ -f $PASSWD_PATH ]]; then
    echo -e "\n---------  purging existing VNC password settings  ---------"
    rm -f $PASSWD_PATH
fi

if [[ $VNC_VIEW_ONLY == "true" ]]; then
    echo "start VNC server in VIEW ONLY mode"
    #create random pw to prevent access
    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20) | vncpasswd -f > $PASSWD_PATH
fi

echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH
chmod 600 $PASSWD_PATH

[[ $DEBUG == true ]] && echo -e "** DEBUG: NO_VNC_HOME is ${NO_VNC_HOME}. Looking for self.pem: \n" $(ls -la $NO_VNC_HOME/self.pem)
[[ $DEBUG == true ]] && echo -e "** DEBUG: STARTUPDIR is ${STARTUPDIR}: \n" $(ls -la $STARTUPDIR)

## start vncserver and noVNC webclient
echo -e "\n------------------ start noVNC  ----------------------------"
[[ $DEBUG == true ]] && echo "$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT"
$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT > $STARTUPDIR/no_vnc_startup.log 2>&1 &
PID_SUB=$!

echo -e "\n------------------ start VNC server ------------------------"

#kill existing VNC server
echo "remove old vnc locks to be a reattachable container killing vncserver for DISPLAY $DISPLAY"
vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \
    || echo "no locks present"

echo -e "start vncserver with param: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION\n..."

# parse start command
[[ $DEBUG == true ]] && echo "vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
    vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
if [[ -f $HOME/.vnc/passwd ]]; then 
    vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"
    echo -e "***DEBUG: $HOME/.vnc/passwd found "
else
    echo -e "**ERROR: NO PASSWORD FILE $HOME/.vnc/passwd !!!"
fi

# parse no password option
#if [[ ${VNC_PASSWORDLESS:-} == "true" ]]; then
#  vnc_cmd="${vnc_cmd} -SecurityTypes None"
#fi

# start using command
# ****FIXME***** - this exits
# vnc command fails?
if [[ $DEBUG == true ]]; then echo "**DEBUG: vnc_cmd: "$vnc_cmd; fi
$vnc_cmd > $STARTUPDIR/no_vnc_startup.log 2>&1

# start WM using auxiliar script
echo -e "start window manager\n..."
$HOME/wm_startup.sh > $STARTUPDIR/wm_startup.log

# log connect options
echo -e "\n\n------------------ VNC environment started ------------------"
echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"

if [[ $DEBUG == true ]]; then
    # if option `-t` or `--tail-log` block the execution and tail the VNC log
    echo -e "\n------------------ All logs in $STARTUPDIR ------------------"
    tail -f $STARTUPDIR/*.log 
    echo -e "\n------------------ /home/default/$HOME/.vnc/$DISPLAY.log ------------------"
    tail -f /home/default/$HOME/.vnc/$DISPLAY.log
fi

if [ -z "$1" ] || [[ $1 =~ -w|--wait ]]; then
    echo "**DEBUG: startup.log current content before WAIT is: \n" $(cat $STARTUPDIR/no_vnc_startup.log)
    wait $PID_SUB
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '$@'"
    exec "$@"
fi
