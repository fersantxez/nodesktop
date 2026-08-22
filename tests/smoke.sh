#!/usr/bin/env bash
set -Eeuo pipefail

container="${1:-nodesktop-v2}"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

docker container inspect "${container}" >/dev/null 2>&1 \
  || fail "Container ${container} does not exist."

health="$(docker inspect --format '{{.State.Health.Status}}' "${container}")"
[[ "${health}" == healthy ]] || fail "Health status is ${health}."

docker exec "${container}" test -s /home/nodesktop/.kasmpasswd \
  || fail "KasmVNC authentication database is empty."
docker exec "${container}" grep -Fqx 'lookupdate-2' /home/nodesktop/.config/nodesktop/style-version \
  || fail "The current style migration was not applied."

runtime="$(docker inspect --format '{{.Config.User}}|{{.HostConfig.Privileged}}|{{.HostConfig.ReadonlyRootfs}}|{{json .HostConfig.CapDrop}}|{{json .HostConfig.SecurityOpt}}|{{(index (index .NetworkSettings.Ports "6901/tcp") 0).HostIp}}' "${container}")"
[[ "${runtime}" == 'nodesktop|false|true|["ALL"]|["no-new-privileges=true"]|127.0.0.1' ]] \
  || fail "Unexpected runtime security settings: ${runtime}"

version_output="$(docker exec "${container}" bash -lc '
  set -u
  printf "Debian="; cat /etc/debian_version
  xfce4-session --version | head -1
  Xvnc -version 2>&1 | grep -m1 KasmVNC || true
  firefox --version 2>&1
  subl --version 2>&1
  geany --version 2>&1
  filezilla --version 2>&1
  transmission-gtk --version 2>&1
  nicotine --version 2>&1
  papers --version 2>&1
  btop --version 2>&1
  7z | grep -m1 "7-Zip" || true
  rclone version | head -1
  tor --version | head -1
')"

style_output="$(docker exec "${container}" bash -lc '
  set -u
  xfconf-query --channel xsettings --property /Net/ThemeName
  xfconf-query --channel xsettings --property /Net/IconThemeName
  xfconf-query --channel xfwm4 --property /general/theme
  xfconf-query --channel thunar --property /default-view
')"

for expected in \
  'Debian=13.6' \
  'xfce4-session 4.20' \
  'KasmVNC 1.5.0' \
  'Mozilla Firefox 154.0' \
  'Sublime Text Build 4200' \
  'geany 2.0' \
  'FileZilla 3.68.1' \
  'transmission-gtk 4.1.3' \
  'Nicotine+ 3.3.10' \
  'Papers 48.3' \
  '1.4.7+' \
  '7-Zip 25.01' \
  'rclone v1.75.0' \
  'Tor version 0.4.9.11'; do
  grep -Fq "${expected}" <<<"${version_output}" \
    || fail "Missing expected version: ${expected}"
done


[[ "${style_output}" == $'Nodesktop-Orchis-Green-Dark-Compact\nNodesktop-Forest\nNodesktop-Orchis-Green-Dark-Compact\nThunarDetailsView' ]] \
  || fail "Unexpected desktop style: ${style_output}"

docker exec "${container}" grep -Eq '^Color_In=(#AFC39D|rgb\(175,195,157\))$' \
  /home/nodesktop/.config/xfce4/panel/netload-17.rc \
  || fail "Network input accent is not sage."
docker exec "${container}" grep -Eq '^Color_Out=(#73875A|rgb\(115,135,90\))$' \
  /home/nodesktop/.config/xfce4/panel/netload-17.rc \
  || fail "Network output accent is not moss olive."
docker exec "${container}" grep -qx 'Update_Interval=5000' \
  /home/nodesktop/.config/xfce4/panel/netload-17.rc \
  || fail "Network monitor refresh interval is not the efficient five-second cadence."
docker exec "${container}" grep -qx 'Timeout_Seconds=5' \
  /home/nodesktop/.config/xfce4/panel/systemload-18.rc \
  || fail "System monitor refresh interval is not the efficient five-second cadence."
docker exec "${container}" grep -qx 'ColorBackground=#111612' \
  /home/nodesktop/.config/xfce4/terminal/terminalrc \
  || fail "Terminal background is not near-black green."
docker exec "${container}" grep -qx 'ColorForeground=#D7DBD2' \
  /home/nodesktop/.config/xfce4/terminal/terminalrc \
  || fail "Terminal foreground is not warm white."
docker exec "${container}" grep -Fq '"extends": "Adaptive.sublime-theme"' \
  /home/nodesktop/.config/sublime-text/Packages/User/Nodesktop.sublime-theme \
  || fail "Sublime does not inherit its supported native layout."
docker exec "${container}" test -s /usr/local/share/btop/themes/nodesktop.theme \
  || fail "The generated btop theme is not installed in btop's search path."
if docker exec "${container}" grep -qiE '#(5294e2|5677fc|4662cf|919caf|86aeff|6c71c4|d3869b)' \
  /usr/local/share/btop/themes/nodesktop.theme; then
  fail "A rejected blue or purple remains in the btop theme."
fi
[[ "$(docker exec "${container}" gsettings get org.gnome.desktop.interface color-scheme)" == "'prefer-dark'" ]] \
  || fail "GTK4/libadwaita does not default to dark mode."
[[ "$(docker exec "${container}" gsettings get org.gnome.desktop.interface accent-color)" == "'green'" ]] \
  || fail "GTK4/libadwaita does not default to a green accent."
[[ "$(docker exec "${container}" gsettings get org.gnome.Papers night-mode)" == true ]] \
  || fail "Papers does not default to its native dark document mode."

docker exec "${container}" test -d /usr/share/themes/Nodesktop-Orchis-Green-Dark-Compact/xfwm4 \
  || fail "Orchis XFWM theme is missing."
docker exec "${container}" test -d /usr/share/icons/Nodesktop-Forest/scalable \
  || fail "Nodesktop Forest icon theme is missing."
for panel_icon in org.xfce.panel.applicationsmenu.svg org.xfce.panel.showdesktop.svg; do
  docker exec "${container}" test -s "/usr/share/icons/Nodesktop-Forest/scalable/apps/${panel_icon}" \
    || fail "Forest panel icon is missing: ${panel_icon}"
done
docker exec "${container}" test -s /usr/share/icons/Nodesktop-Forest/scalable/places/user-desktop.svg \
  || fail "Semantic green Desktop folder icon is missing."
docker exec "${container}" dpkg-query -W -f='${Status}' librsvg2-common \
  | grep -Fq 'install ok installed' \
  || fail "GTK SVG icon loader is missing."
docker exec "${container}" test -s /var/lib/dpkg/status \
  || fail "The package database was removed; inventory and security correlation would be broken."
if docker exec "${container}" grep -rqiE \
  '#(5294e2|5677fc|4662cf|919caf|86aeff)' \
  /usr/share/icons/Nodesktop-Forest/scalable; then
  fail "Blue palette remains in the active icon theme."
fi
if docker exec "${container}" grep -q '<circle' \
  /usr/share/icons/Nodesktop-Forest/scalable/places/folder.svg; then
  fail "The rejected circular generic folder icon remains active."
fi
generic_folder_hash="$(docker exec "${container}" sha256sum \
  /usr/share/icons/Nodesktop-Forest/scalable/places/folder.svg \
  | cut -d' ' -f1)"
download_folder_hash="$(docker exec "${container}" sha256sum \
  /usr/share/icons/Nodesktop-Forest/scalable/places/folder-download.svg \
  | cut -d' ' -f1)"
[[ "${generic_folder_hash}" != "${download_folder_hash}" ]] \
  || fail "Downloads does not have a distinct semantic folder icon."

printf '%s\n' "${version_output}"
printf '%s\n' "${style_output}"
printf 'PASS: health, versions, desktop style, and runtime hardening verified for %s.\n' "${container}"
