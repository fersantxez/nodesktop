#!/usr/bin/env bash
set -Eeuo pipefail

image="${NODEDESKTOP_IMAGE:-nodesktop:3.0.0-full}"
name="${1:-nodesktop-v3}"
port="${NODEDESKTOP_PORT:-6901}"
resolution="${NODEDESKTOP_RESOLUTION:-1440x900}"
ui_scale="${NODEDESKTOP_UI_SCALE:-100}"
password_file="${NODEDESKTOP_PASSWORD_FILE:-}"

fail() {
  printf 'nodesktop: %s\n' "$*" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || fail "Docker is required."
[[ "${name}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail "Invalid container name: ${name}"
if [[ ! "${port}" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
  fail "Invalid NODEDESKTOP_PORT: ${port}"
fi
[[ "${resolution}" =~ ^[0-9]+x[0-9]+$ ]] \
  || fail "Invalid NODEDESKTOP_RESOLUTION: ${resolution}"
[[ "${ui_scale}" == 100 || "${ui_scale}" == 125 ]] \
  || fail "NODEDESKTOP_UI_SCALE must be 100 or 125."

if docker container inspect "${name}" >/dev/null 2>&1; then
  fail "A container named ${name} already exists. Remove or rename it first."
fi

if ! docker image inspect "${image}" >/dev/null 2>&1; then
  printf 'Building %s...\n' "${image}"
  docker build --target production --tag "${image}" .
fi

password=""
if [[ -n "${password_file}" ]]; then
  [[ -f "${password_file}" && -r "${password_file}" ]] \
    || fail "NODEDESKTOP_PASSWORD_FILE is not readable."
  IFS= read -r password < "${password_file}" || true
else
  read -r -s -p "Choose a desktop password (12+ characters): " password
  printf '\n'
fi
(( ${#password} >= 12 )) || fail "The desktop password must contain at least 12 characters."

secret_volume="${name}-secret"
home_volume="${name}-home"
docker volume create "${secret_volume}" >/dev/null
docker volume create "${home_volume}" >/dev/null

printf '%s\n' "${password}" \
  | docker run --rm --interactive \
      --user 0 \
      --entrypoint /bin/sh \
      --volume "${secret_volume}:/secret" \
      "${image}" \
      -c 'umask 0333; IFS= read -r secret; printf "%s\n" "$secret" > /secret/vnc_password; chmod 0444 /secret/vnc_password'
unset password

docker run --detach \
  --name "${name}" \
  --restart unless-stopped \
  --publish "127.0.0.1:${port}:6901" \
  --env "VNC_RESOLUTION=${resolution}" \
  --env "NODESKTOP_UI_SCALE=${ui_scale}" \
  --cap-drop ALL \
  --security-opt no-new-privileges=true \
  --read-only \
  --tmpfs /tmp:rw,nosuid,nodev,noexec,mode=1777,size=512m \
  --tmpfs /run:rw,nosuid,nodev,noexec,mode=755,size=64m \
  --shm-size 512m \
  --volume "${home_volume}:/home/nodesktop" \
  --volume "${secret_volume}:/run/secrets:ro" \
  "${image}" >/dev/null

printf 'Nodesktop is starting at https://127.0.0.1:%s\n' "${port}"
printf 'Username: nodesktop\n'
printf 'Check readiness with: docker inspect --format={{.State.Health.Status}} %s\n' "${name}"
