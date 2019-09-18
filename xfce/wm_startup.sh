
#!/usr/bin/env bash
### every exit != 0 fails the script
#set -e

set -x #show every command as executed in log

echo -e "\n------------------ startup of Xfce4 window manager ------------------"

if [[ $DEBUG == true ]]; then
 echo -e "start XFCE4\n..."
fi
/usr/bin/startxfce4 --replace > $HOME/wm.log &
sleep 1
cat $HOME/wm.log

### hack to kill redundant panel
export FIRST_PANEL_PID=$(ps aux|grep xfce4-panel| head -n1| awk {'print $2'})
kill $FIRST_PANEL_PID

### disable screensaver and power management
xset -dpms &
xset s noblank &
xset s off 

#TODO: run this only if the container is running as privileged
#link /home/$USER with /headless
USER=$(whoami)
sudo ln -s /headless /home/${USER}
sudo chown ${USER}:${USER} /home/${USER}
