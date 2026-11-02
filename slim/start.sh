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
startup_file="$HOME/.vnc/slim-xstartup"
cat > "$startup_file" <<'START'
#!/bin/sh
xsetroot -solid '#202020'
xterm -fa 'DejaVu Sans Mono' -fs 12 -title 'Nodesktop Slim' -e sh -c 'printf "Right-click the desktop for applications.\\n"; exec bash' &
exec dbus-run-session openbox-session
START
chmod 700 "$startup_file"
touch "$HOME/.vnc/.de-was-selected"
certificate_args=()
if [[ ! -r /etc/ssl/certs/ssl-cert-snakeoil.pem || ! -r /etc/ssl/private/ssl-cert-snakeoil.key ]]; then
  cert_file="$HOME/.vnc/slim-self.pem"
  if [[ ! -r "$cert_file" ]]; then
    openssl req -new -x509 -nodes -days 365 -subj '/CN=nodesktop-slim' \
      -keyout "$XDG_RUNTIME_DIR/slim-key.pem" -out "$XDG_RUNTIME_DIR/slim-cert.pem" >/dev/null 2>&1
    cat "$XDG_RUNTIME_DIR/slim-cert.pem" "$XDG_RUNTIME_DIR/slim-key.pem" > "$cert_file"
    chmod 600 "$cert_file"
  fi
  tls_override="$XDG_RUNTIME_DIR/slim-tls.yaml"
  cat > "$tls_override" <<TLS
network:
  ssl:
    pem_certificate: $cert_file
    pem_key: $cert_file
    require_ssl: true
TLS
  config_list="/usr/share/kasmvnc/kasmvnc_defaults.yaml,/etc/kasmvnc/kasmvnc.yaml"
  [[ ! -f "$HOME/.vnc/kasmvnc.yaml" ]] || config_list+=",$HOME/.vnc/kasmvnc.yaml"
  certificate_args=(-config "$config_list,$tls_override")
fi
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
/usr/local/bin/nodesktop-http-redirect.py --listen "$VNC_PORT" --backend "$VNC_BACKEND_PORT" &
relay=$!
vncserver "$VNC_DISPLAY" -fg -geometry "$VNC_RESOLUTION" -depth 24 -interface 127.0.0.1 -websocketPort "$VNC_BACKEND_PORT" -xstartup "$startup_file" "${certificate_args[@]}" &
vnc=$!
trap 'kill -TERM "$vnc" "$relay" 2>/dev/null || true' EXIT INT TERM
wait "$vnc"
