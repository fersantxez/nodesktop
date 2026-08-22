#!/usr/bin/env bash
set -Eeuo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo}"

while IFS= read -r script; do
  bash -n "${script}"
done < <(find . -type f -name '*.sh' -not -path './.git/*' -print | sort)

while IFS= read -r document; do
  xmllint --noout "${document}"
done < <(find config xfce assets -type f \( -name '*.xml' -o -name '*.svg' \) -print | sort)

while IFS= read -r document; do
  jq -e . "${document}" >/dev/null
done < <(find config assets -type f -name '*.json' -print | sort)

python3 -m py_compile scripts/migrate-style.py scripts/nodesktop-style-rollback scripts/render_visual_assets.py
scripts/build-visual-assets.sh --check
tests/style-migration.sh
docker build --check .

if rg -n --hidden --glob '!.git/**' --glob '!.secrets/**' \
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' .; then
  printf 'FAIL: a likely committed secret was found.\n' >&2
  exit 1
fi

printf 'PASS: shell, XML/SVG, JSON, Python, generated assets, migration, Dockerfile, and secret guards.\n'
