
#!/usr/bin/env bash
### every exit != 0 fails the script
#set -e

set -x #show every command as executed in log

echo -e "\n------------------ startup of Xfce4 window manager ------------------"

### start WM
[[ $DEBUG == true ]] && echo -e "start XFCE4\n..."

#/usr/bin/startxfce4 --replace > $HOME/wm.log 2>&1 &
xfce4-session --display=$VNC_IP:1 > $HOME/wm.log 2>&1 &  #FER
sleep 1
cat $HOME/wm.log

### hack to kill redundant panel
export FIRST_PANEL_PID=$(ps aux|grep xfce4-panel| head -n1| awk {'print $2'})
[[ $DEBUG == true ]] && echo -e "Killing Panel with ID: $FIRST_PANEL_PID ...\n"
kill $FIRST_PANEL_PID

### hack to kill vnc_config that makes notification area lose selection
export TIGERVNNCONFIG_PID=$(ps aux|grep tigervncconfig| head -n1| awk {'print $2'})
[[ $DEBUG == true ]] && echo -e "Killing TigerVNCconfig with ID: $TIGERVNCCONFIG_PID ...\n"
kill $TIGERVNNCONFIG_PID

### disable power management
[[ $DEBUG == true ]] && echo -e "Disable Xsec, DPMS\n..."
xhost + && \
xset -dpms




