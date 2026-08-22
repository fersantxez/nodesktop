#!/usr/bin/env bash
set -Eeuo pipefail

image="${1:-nodesktop:3-lookupdate-arm64-r3}"
secret_volume="${2:-nodesktop-v3-secret}"
runs="${NODESKTOP_PERF_RUNS:-5}"
prefix="nodesktop-perf-$$"
results="$(mktemp)"

cleanup() {
  for index in $(seq 1 "${runs}"); do
    docker rm -f "${prefix}-${index}" >/dev/null 2>&1 || true
    docker volume rm "${prefix}-${index}-home" >/dev/null 2>&1 || true
  done
  rm -f "${results}"
}
trap cleanup EXIT

docker image inspect "${image}" >/dev/null
docker volume inspect "${secret_volume}" >/dev/null

for index in $(seq 1 "${runs}"); do
  name="${prefix}-${index}"
  home="${name}-home"
  docker volume create "${home}" >/dev/null
  started="$(python3 -c 'import time; print(time.time_ns())')"
  docker run -d --name "${name}" \
    --user nodesktop \
    --cap-drop ALL \
    --security-opt no-new-privileges=true \
    --read-only \
    --tmpfs /tmp:rw,nosuid,nodev,noexec,mode=1777,size=256m \
    --tmpfs /run:rw,nosuid,nodev,noexec,mode=755,size=32m \
    --volume "${home}:/home/nodesktop" \
    --volume "${secret_volume}:/run/secrets:ro" \
    "${image}" >/dev/null
  for _ in $(seq 1 150); do
    health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${name}")"
    [[ "${health}" == healthy ]] && break
    sleep 0.1
  done
  [[ "${health}" == healthy ]] || { docker logs "${name}"; exit 1; }
  finished="$(python3 -c 'import time; print(time.time_ns())')"
  python3 -c 'import sys; print((int(sys.argv[2])-int(sys.argv[1]))/1e9)' "${started}" "${finished}" >> "${results}"
  docker stop --time 10 "${name}" >/dev/null
  docker rm "${name}" >/dev/null
  docker volume rm "${home}" >/dev/null
done

python3 - "${results}" <<'PY'
import statistics
import sys
values = sorted(float(line) for line in open(sys.argv[1]) if line.strip())
p95_index = max(0, min(len(values) - 1, round(.95 * len(values) + .5) - 1))
print("cold_start_seconds=" + ",".join(f"{value:.3f}" for value in values))
print(f"cold_start_p50_seconds={statistics.median(values):.3f}")
print(f"cold_start_p95_seconds={values[p95_index]:.3f}")
if values[p95_index] > 15:
    raise SystemExit("FAIL: cold-start p95 exceeds 15 seconds")
PY

printf 'PASS: %s clean cold starts completed within the 15-second gate.\n' "${runs}"
