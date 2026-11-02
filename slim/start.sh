#!/usr/bin/env bash
set -Eeuo pipefail
if (( $# )); then exec "$@"; fi
password="${VNC_PW:-}"
if [[ -z "$password" ]]; then
  IFS= read -r password < "${VNC_PASSWORD_FILE:-/run/secrets/vnc_password}" || true
fi
[[ ${#password} -ge 12 ]] || { echo 'A password of at least 12 characters is required.' >&2; exit 64; }
[[ "$VNC_RESOLUTION" =~ ^[0-9]+x[0-9]+$ ]] || exit 64
install -d -m 0700 "$HOME/.vnc" "$XDG_RUNTIME_DIR" "$HOME/.config/openbox"
install -d -m 1777 /tmp/.X11-unix /tmp/.ICE-unix
printf '%s\n%s\n' "$password" "$password" | vncpasswd -u "$VNC_USER" -w -o "$HOME/.kasmpasswd"
unset password
cat > "$HOME/.vnc/xstartup" <<'START'
#!/bin/sh
xsetroot -solid '#202020'
xterm -fa 'DejaVu Sans Mono' -fs 12 -title 'Nodesktop Slim' -e sh -c 'printf "Right-click the desktop for applications.\\n"; exec bash' &
exec dbus-run-session openbox-session
START
chmod 700 "$HOME/.vnc/xstartup"
touch "$HOME/.vnc/.de-was-selected"
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
/usr/local/bin/nodesktop-http-redirect.py --listen "$VNC_PORT" --backend "$VNC_BACKEND_PORT" &
relay=$!
vncserver "$VNC_DISPLAY" -fg -geometry "$VNC_RESOLUTION" -depth 24 -interface 127.0.0.1 -websocketPort "$VNC_BACKEND_PORT" &
vnc=$!
trap 'kill -TERM "$vnc" "$relay" 2>/dev/null || true' EXIT INT TERM
wait "$vnc"
