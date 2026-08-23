#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# > 0 )); then
  exec "$@"
fi

ui_scale="${NODESKTOP_UI_SCALE:-100}"
if [[ "${ui_scale}" != 100 && "${ui_scale}" != 125 ]]; then
  printf 'NODESKTOP_UI_SCALE must be 100 or 125, not %s.\n' "${ui_scale}" >&2
  exit 64
fi
/usr/local/bin/migrate-style.py --home "${HOME}" --scale "${ui_scale}"

password_file="${VNC_PASSWORD_FILE:-/run/secrets/vnc_password}"
vnc_password="${VNC_PW:-}"
if [[ -z "${vnc_password}" ]]; then
  if [[ ! -f "${password_file}" || ! -r "${password_file}" ]]; then
    printf 'A readable VNC password file is required at %s.\n' "${password_file}" >&2
    exit 64
  fi
  IFS= read -r vnc_password < "${password_file}" || true
fi
minimum_password_length=12
if [[ -n "${VNC_PW:-}" ]]; then
  # Keep compatibility with the legacy TrueNAS manifest, whose existing
  # password is shorter than the modern secret-file policy.
  minimum_password_length=8
fi
if (( ${#vnc_password} < minimum_password_length )); then
  printf 'The VNC password must contain at least %s characters.\n' "${minimum_password_length}" >&2
  exit 64
fi

if [[ ! "${VNC_RESOLUTION}" =~ ^[0-9]+x[0-9]+$ ]]; then
  printf 'Invalid VNC_RESOLUTION: %s\n' "${VNC_RESOLUTION}" >&2
  exit 64
fi
if [[ ! "${VNC_PORT}" =~ ^[0-9]+$ || ! "${VNC_BACKEND_PORT}" =~ ^[0-9]+$ || "${VNC_PORT}" == "${VNC_BACKEND_PORT}" ]]; then
  printf 'VNC_PORT and VNC_BACKEND_PORT must be different numeric ports.\n' >&2
  exit 64
fi

# XFCE stores the horizontal panel center in pixels. Derive it from the
# requested framebuffer so the compact launcher/status rail stays centered
# across local and HQ resolutions instead of drifting to the left edge.
panel_width="${VNC_RESOLUTION%x*}"
panel_center=$((panel_width / 2))
panel_xml="${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
if [[ -f "${panel_xml}" ]]; then
  PANEL_CENTER="${panel_center}" python3 - "${panel_xml}" <<'PY'
import os
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
center = os.environ["PANEL_CENTER"]
updated, count = re.subn(
    r'(value="p=12;x=)[0-9]+(;y=0"/>)',
    rf'\g<1>{center}\g<2>',
    text,
    count=1,
)
if count:
    path.write_text(updated, encoding="utf-8")
PY
fi

# The XFCE session can restore its own panel state after the XML defaults are
# read. Retry through xfconf once the session bus/panel is available so the
# running panel uses the same framebuffer-derived center.
(
  for _ in {1..30}; do
    if DISPLAY="${VNC_DISPLAY}" xfconf-query \
      -c xfce4-panel \
      -p /panels/panel-2/position \
      -s "p=12;x=${panel_center};y=0" >/dev/null 2>&1; then
      DISPLAY="${VNC_DISPLAY}" xfconf-query \
        -c xfwm4 -p /general/title_font -s "Inter Variable 10" >/dev/null 2>&1 || true
      DISPLAY="${VNC_DISPLAY}" xfconf-query \
        -c xsettings -p /Gtk/FontName -s "Inter Variable 10" >/dev/null 2>&1 || true
      DISPLAY="${VNC_DISPLAY}" xfconf-query \
        -c xsettings -p /Net/IconThemeName -s "Nodesktop-Forest" >/dev/null 2>&1 || true
      break
    fi
    sleep 1
  done
) &

install -d -m 0700 "${HOME}/.vnc" "${XDG_RUNTIME_DIR}"
chmod 0700 "${XDG_RUNTIME_DIR}"
install -d -m 1777 /tmp/.X11-unix /tmp/.ICE-unix

# Legacy TrueNAS manifests bind-mount the host account database.  That changes
# the container's supplementary groups, so the packaged snake-oil key may no
# longer be readable through the ssl-cert group.  Keep the historical mounts
# working by creating a per-user certificate and overriding only the KasmVNC
# SSL paths when the packaged key is unavailable.
if [[ ! -r /etc/ssl/certs/ssl-cert-snakeoil.pem || ! -r /etc/ssl/private/ssl-cert-snakeoil.key ]]; then
  cert_dir="${XDG_RUNTIME_DIR}/nodesktop-cert"
  cert_file="${HOME}/.vnc/self.pem"
  if [[ ! -r "${cert_file}" ]]; then
    install -d -m 0700 "${cert_dir}"
    openssl req -new -x509 -nodes -days 365 \
      -out "${cert_dir}/cert.pem" \
      -keyout "${cert_dir}/key.pem" \
      -subj "/C=US/ST=NY/L=New York/O=Nodesktop/OU=Nodesktop/CN=nodesktop" \
      >/dev/null 2>&1
    cat "${cert_dir}/cert.pem" "${cert_dir}/key.pem" > "${cert_file}"
    chmod 0600 "${cert_file}"
  fi
  cat > "${HOME}/.vnc/kasmvnc.yaml" <<EOF
network:
  ssl:
    pem_certificate: ${cert_file}
    pem_key: ${cert_file}
    require_ssl: true
EOF
fi

printf '%s\n%s\n' "${vnc_password}" "${vnc_password}" \
  | vncpasswd -u "${VNC_USER}" -w -o "${HOME}/.kasmpasswd"
unset vnc_password

rm -f "/tmp/.X1-lock"
rm -f "/tmp/.X11-unix/X1"

printf 'Nodesktop is starting at https://0.0.0.0:%s (HTTP redirects enabled; display %s, %s).\n' \
  "${VNC_PORT}" "${VNC_DISPLAY}" "${VNC_RESOLUTION}"

"/usr/local/bin/nodesktop-http-redirect.py" \
  --listen "${VNC_PORT}" \
  --backend "${VNC_BACKEND_PORT}" &
redirect_pid=$!

vncserver "${VNC_DISPLAY}" \
  -fg \
  -select-de xfce \
  -geometry "${VNC_RESOLUTION}" \
  -depth 24 \
  -interface 0.0.0.0 \
  -websocketPort "${VNC_BACKEND_PORT}" &
vnc_pid=$!

cleanup() {
  kill -TERM "${vnc_pid}" "${redirect_pid}" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

wait "${vnc_pid}"
