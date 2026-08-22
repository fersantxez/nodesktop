#!/usr/bin/env bash
set -Eeuo pipefail

version="${1:-3.0.0}"
repository="${NODESKTOP_REPOSITORY:-fernandosanchez/nodesktop}"
debian_release="${NODESKTOP_DEBIAN_RELEASE:-trixie}"
immutable_tag="${repository}:${version}-${debian_release}"
revision="${NODESKTOP_REVISION:-$(git rev-parse HEAD)}"
created="${SOURCE_DATE_EPOCH:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

[[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.]+)?$ ]] || {
  printf 'Invalid release version: %s\n' "${version}" >&2
  exit 64
}

[[ "${debian_release}" =~ ^[a-z][a-z0-9-]*$ ]] || {
  printf 'Invalid Debian release name: %s\n' "${debian_release}" >&2
  exit 64
}

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target production \
  --build-arg "VERSION=${version}" \
  --build-arg "REVISION=${revision}" \
  --build-arg "CREATED=${created}" \
  --tag "${immutable_tag}" \
  --tag "${repository}:${version}" \
  --tag "${repository}:${debian_release}" \
  --tag "${repository}:latest" \
  --sbom=true \
  --provenance=mode=max \
  --push \
  .

docker buildx imagetools inspect "${immutable_tag}"
