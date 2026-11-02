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
  ! command -v vlc >/dev/null
  ! command -v pulseaudio >/dev/null
  test "$(curl -ks -o /dev/null -w "%{http_code}" https://127.0.0.1:6901/)" = 401
  test "$(curl -ks -u "$VNC_USER:$VNC_PW" -o /dev/null -w "%{http_code}" https://127.0.0.1:6901/)" = 200
'
printf 'PASS: Slim desktop, tools, authentication and HTTPS.\n'
