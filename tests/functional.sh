#!/usr/bin/env bash
set -Eeuo pipefail

container="${1:-nodesktop-v3-clean}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

docker inspect "${container}" >/dev/null 2>&1 || fail "missing container ${container}"
[[ "$(docker inspect --format '{{.State.Health.Status}}' "${container}")" == healthy ]] \
  || fail "${container} is not healthy"

if docker exec "${container}" pgrep -f \
  'firefox|sublime_text|geany|filezilla|transmission-gtk|nicotine|papers' >/dev/null; then
  fail "a heavyweight desktop application started without user action"
fi

docker exec "${container}" bash -lic \
  '[[ ${BASH_IT_THEME} == zork ]] && [[ -r /opt/bash-it/bash_it.sh ]]' \
  || fail "Bash-it with Zork is not active for the default user"

for family in 'Inter Variable' 'JetBrains Mono' 'Newsreader'; do
  docker exec "${container}" fc-match "${family}" | grep -Fq "${family%% Variable}" \
    || fail "font does not resolve: ${family}"
done

docker exec "${container}" bash -lc '
  set -Eeuo pipefail
  root="$HOME/.cache/nodesktop-e2e"
  rm -rf "$root"
  mkdir -p "$root/source" "$root/copied" "$root/extracted"
  printf "%s\n" "Nodesktop E2E" "español: acción" "CJK: 中文" > "$root/source/specimen.txt"
  rclone copy "$root/source" "$root/copied"
  cmp "$root/source/specimen.txt" "$root/copied/specimen.txt"
  7z a -bd -y "$root/specimen.7z" "$root/source/specimen.txt" >/dev/null
  7z t "$root/specimen.7z" >/dev/null
  7z x -bd -y -o"$root/extracted" "$root/specimen.7z" >/dev/null
  cmp "$root/source/specimen.txt" "$root/extracted/specimen.txt"
  cp "$root/source/specimen.txt" "$HOME/nodesktop-e2e.txt"
' || fail "rclone/7zip/local fixture workflow failed"

launch_check() {
  local pattern="$1"
  shift
  docker exec -d -u nodesktop -e DISPLAY=:1 "${container}" "$@"
  for _ in {1..20}; do
    if docker exec "${container}" pgrep -f "${pattern}" >/dev/null; then
      # The test container is disposable. SIGKILL avoids application-specific
      # quit-confirmation dialogs from contaminating the next launcher check.
      docker exec "${container}" pkill -KILL -f "${pattern}" >/dev/null 2>&1 || true
      return 0
    fi
    sleep 0.25
  done
  fail "GUI application did not launch: $*"
}

launch_check 'xfce4-terminal' xfce4-terminal --disable-server
launch_check 'thunar' thunar --window /home/nodesktop
launch_check 'geany' geany --new-instance /home/nodesktop/nodesktop-e2e.txt
launch_check 'papers' papers /home/nodesktop/nodesktop-e2e.txt
launch_check 'sublime_text' subl --new-window /home/nodesktop/nodesktop-e2e.txt
launch_check 'filezilla' filezilla
launch_check 'transmission-gtk' transmission-gtk
launch_check 'nicotine' nicotine
launch_check '/opt/firefox/firefox' firefox --new-instance about:blank
# Firefox's parent process normalizes argv[0] to `firefox`, while its child
# processes retain the absolute path used by the launcher check. Ensure the
# disposable test leaves no surviving parent or crash-reporter process.
docker exec "${container}" pkill -KILL -x firefox-bin >/dev/null 2>&1 || true

if docker exec "${container}" test -x \
  /home/nodesktop/Applications/tor-browser/start-tor-browser.desktop; then
  docker exec -d -u nodesktop -e DISPLAY=:1 "${container}" \
    /usr/local/bin/nodesktop-tor-browser
  tor_browser_started=false
  for _ in {1..60}; do
    if docker exec "${container}" pgrep -f \
      '/home/nodesktop/Applications/tor-browser/Browser/firefox.real' >/dev/null; then
      tor_browser_started=true
      break
    fi
    sleep 0.5
  done
  [[ "${tor_browser_started}" == true ]] \
    || fail "official Tor Browser did not launch"
  docker exec "${container}" pkill -KILL -f \
    '/home/nodesktop/Applications/tor-browser/Browser/firefox.real' >/dev/null 2>&1 || true
fi

printf 'PASS: clean startup, Bash-it/Zork, fonts, rclone, 7zip, and every GUI launcher including Tor Browser when installed.\n'
