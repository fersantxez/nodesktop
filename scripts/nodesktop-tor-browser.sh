#!/usr/bin/env bash
set -Eeuo pipefail

official_launcher="${HOME}/Applications/tor-browser/start-tor-browser.desktop"
if [[ -x "${official_launcher}" ]]; then
  exec "${official_launcher}" --detach
fi

tor_data_dir="${HOME}/.local/share/tor"
install -d -m 0700 "${tor_data_dir}"

if ! pgrep --exact tor >/dev/null; then
  tor --RunAsDaemon 1 \
      --DataDirectory "${tor_data_dir}" \
      --SocksPort 127.0.0.1:9050 \
      --CookieAuthentication 0
fi

exec /usr/local/bin/firefox \
  --no-remote \
  --profile "${HOME}/.mozilla/nodesktop-tor"
