# Configuration-only AMD64 maintenance release for HQ. Build from repo root:
# docker build -f releases/3.0.6-cpu-saver.Dockerfile --build-arg REVISION=$(git rev-parse HEAD) -t fernandosanchez/nodesktop:3.0.6-cpu-saver .
# The normal Dockerfile also includes this policy for subsequent full builds.
FROM fernandosanchez/nodesktop:3.0.5-dank-neon@sha256:5782d1aeea4160c39e953cbcd0381daa64d33a6eb84a647daa73b99495d1f194

ARG REVISION=unknown
ARG CREATED=unknown
LABEL org.opencontainers.image.version="3.0.6-cpu-saver" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.created="${CREATED}"

COPY config/kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
