#!/usr/bin/env bash
set -Eeuo pipefail

source_dir="${1:?source KasmVNC web directory required}"
target_dir="${2:?target directory required}"
assets_dir="${3:?Nodesktop KasmVNC assets directory required}"

[[ -f "${source_dir}/index.html" && -f "${source_dir}/vnc.html" ]] || {
  printf 'KasmVNC 1.5.0 web anchors are missing.\n' >&2
  exit 1
}
grep -Fq '<title>KasmVNC</title>' "${source_dir}/index.html" || {
  printf 'Unexpected KasmVNC index title anchor; refusing an unscoped patch.\n' >&2
  exit 1
}
grep -Fq 'id="noVNC_control_bar"' "${source_dir}/index.html" || {
  printf 'Unexpected KasmVNC control-bar anchor; refusing an unscoped patch.\n' >&2
  exit 1
}

install -d "${target_dir}"
cp -a "${source_dir}/." "${target_dir}/"
install -m 0644 "${assets_dir}/nodesktop.css" "${target_dir}/nodesktop.css"
install -m 0644 "${assets_dir}/nodesktop-web-tokens.css" "${target_dir}/nodesktop-web-tokens.css"
install -m 0644 "${assets_dir}/nodesktop-mark.svg" "${target_dir}/nodesktop-mark.svg"

for page in index.html vnc.html screen.html disconnected.html; do
  [[ -f "${target_dir}/${page}" ]] || continue
  sed -i 's#</head>#<link rel="icon" type="image/svg+xml" href="./nodesktop-mark.svg"><link rel="stylesheet" href="./nodesktop.css"></head>#' "${target_dir}/${page}"
done
sed -i 's#<title>KasmVNC</title>#<title>Nodesktop</title>#' "${target_dir}/index.html"

grep -Fq 'href="./nodesktop.css"' "${target_dir}/index.html"
grep -Fq '<title>Nodesktop</title>' "${target_dir}/index.html"
