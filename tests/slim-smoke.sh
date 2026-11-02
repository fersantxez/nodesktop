#!/usr/bin/env bash
set -Eeuo pipefail
container="${1:?provide a disposable Slim container}"
docker exec "$container" sh -c '
  set -eu
  pgrep -x Xvnc >/dev/null
  pgrep -x openbox >/dev/null
  command -v firefox-esr >/dev/null
  command -v mousepad >/dev/null
  command -v xterm >/dev/null
  command -v thunar >/dev/null
  fc-match -f "%{family}\n" :lang=zh-cn | grep -qi "WenQuanYi"
  fc-match -f "%{family}\n" emoji | grep -qi "Noto Color Emoji"
  ! command -v vlc >/dev/null
  ! command -v pulseaudio >/dev/null
  test "$(curl -ks -o /dev/null -w "%{http_code}" https://127.0.0.1:6901/)" = 401
  password="${VNC_PW:-}"
  if [ -z "$password" ]; then IFS= read -r password < "${VNC_PASSWORD_FILE:-/run/secrets/vnc_password}"; fi
  test "$(curl -ks -u "$VNC_USER:$password" -o /dev/null -w "%{http_code}" https://127.0.0.1:6901/)" = 200
'
printf 'PASS: Slim desktop, tools, authentication and HTTPS.\n'
