#!/usr/bin/env bash
set -Eeuo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "${fixture}"' EXIT
defaults="${fixture}/defaults"
home="${fixture}/home"
mkdir -p "${defaults}" "${home}/.config/xfce4/xfconf/xfce-perchannel-xml"
cp -R "${repo}/config/xfce4" "${defaults}/xfce4"
cp -R "${repo}/config/generated" "${defaults}/generated"
cp -R "${repo}/config/sublime/Packages/User" "${defaults}/sublime"
cp -R "${repo}/config/geany" "${defaults}/geany"
cp -R "${repo}/config/btop" "${defaults}/btop"
cp "${repo}/config/bashrc" "${defaults}/bashrc"
cp "${repo}/config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" \
  "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
sed -i.bak 's/Inter Variable 10/Roobert Light 10/; s/JetBrains Mono 11/Inconsolata Medium 12/' \
  "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
rm "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml.bak"
printf '%s\n' 'export BASH_IT_THEME=clean' 'export MY_SETTING=preserved' > "${home}/.bashrc"

"${repo}/scripts/migrate-style.py" --home "${home}" --defaults "${defaults}" --scale 125
grep -Fq 'value="Inter Variable 11"' "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
grep -Fq 'value="120"' "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
grep -Fq 'export BASH_IT_THEME=zork' "${home}/.bashrc"
grep -Fq 'export MY_SETTING=preserved' "${home}/.bashrc"
grep -Fqx 'lookupdate-2' "${home}/.config/nodesktop/style-version"
test -s "${home}/.config/sublime-text/Packages/User/Nodesktop.sublime-color-scheme"
before="$(find "${home}/.config/nodesktop/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
"${repo}/scripts/migrate-style.py" --home "${home}" --defaults "${defaults}" --scale 125
after="$(find "${home}/.config/nodesktop/backups" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
[[ "${before}" == "${after}" ]]

# A pristine migrated file rolls back, while a later user edit is protected.
"${repo}/scripts/nodesktop-style-rollback" --home "${home}"
grep -Fq 'value="Roobert Light 10"' "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
grep -Fqx 'forest-semantic-4' "${home}/.config/nodesktop/style-version"

rm -rf "${home}"
mkdir -p "${home}/.config/xfce4/xfconf/xfce-perchannel-xml"
cp "${repo}/config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" \
  "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
sed -i.bak 's/Inter Variable 10/Roobert Light 10/' \
  "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
rm "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml.bak"
"${repo}/scripts/migrate-style.py" --home "${home}" --defaults "${defaults}" --scale 100
printf '\n<!-- user edit -->\n' >> "${home}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
if "${repo}/scripts/nodesktop-style-rollback" --home "${home}" >/dev/null 2>&1; then
  fail="rollback unexpectedly overwrote a post-migration user edit"
  printf 'FAIL: %s\n' "${fail}" >&2
  exit 1
fi
printf 'PASS: style migration is safe, persistent, and idempotent.\n'
