#!/usr/bin/env bash
set -Eeuo pipefail

container="${1:?usage: tests/encoding.sh CONTAINER}"

# Check the running X server, including merged per-user configuration, rather
# than merely checking the YAML shipped in the image.
for setting in 'videoCodec=' 'FrameRate=15' 'RectThreads=2' \
  'WebpEncodingTime=0' 'IgnoreClientSettingsKasm=1'; do
  key="${setting%%=*}"
  expected="${setting#*=}"
  actual="$(docker exec "${container}" timeout 5 vncconfig -get "${key}")"
  [[ "${actual}" == "${expected}" ]] || {
    printf 'FAIL: %s expected <%s>, got <%s>\n' "${key}" "${expected}" "${actual}" >&2
    exit 1
  }
done

printf 'PASS: running Xvnc uses the CPU-saving encoding policy.\n'
