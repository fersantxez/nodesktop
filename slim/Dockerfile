# syntax=docker/dockerfile:1.7
FROM debian:13.6-slim@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258
ARG TARGETARCH
ARG KASMVNC_VERSION=1.5.0
ARG KASMVNC_SHA256_AMD64=80b241de7dfe53bba2b7e1cc5ac8c5246d72271efa16be2d4f76607f30fab1c4
ARG KASMVNC_SHA256_ARM64=fbb11589958a2acccd2d67f67944be79ac1e8e3a1d6172c0e6db6dc59e55a919
ENV DEBIAN_FRONTEND=noninteractive HOME=/home/nodesktop DISPLAY=:1 VNC_DISPLAY=:1 VNC_PORT=6901 VNC_BACKEND_PORT=6902 VNC_RESOLUTION=1440x900 VNC_USER=nodesktop XDG_RUNTIME_DIR=/tmp/runtime-nodesktop LANG=C.UTF-8
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl dbus-x11 desktop-file-utils firefox-esr mousepad openbox thunar xterm xdg-utils procps ssl-cert tini x11-xserver-utils \
 && case "$TARGETARCH" in amd64) ksha="$KASMVNC_SHA256_AMD64";; arm64) ksha="$KASMVNC_SHA256_ARM64";; *) exit 1;; esac \
 && f="kasmvncserver_trixie_${KASMVNC_VERSION}_${TARGETARCH}.deb" \
 && curl -fsSL --retry 5 -o "/tmp/$f" "https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/$f" \
 && echo "$ksha  /tmp/$f" | sha256sum -c \
 && apt-get install -y --no-install-recommends "/tmp/$f" \
 && groupadd --gid 1000 nodesktop && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash nodesktop && usermod -aG ssl-cert nodesktop \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*
# Keep multilingual text and emoji readable in the remote browser.
RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-wqy-zenhei fonts-noto-color-emoji \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
COPY slim/start.sh /usr/local/bin/nodesktop-slim-start
COPY slim/menu.xml /etc/xdg/openbox/menu.xml
COPY slim/kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY scripts/nodesktop-http-redirect.py /usr/local/bin/nodesktop-http-redirect.py
RUN chmod 0755 /usr/local/bin/nodesktop-slim-start /usr/local/bin/nodesktop-http-redirect.py
USER nodesktop
WORKDIR /home/nodesktop
EXPOSE 6901
VOLUME ["/home/nodesktop"]
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=6 CMD pgrep -x Xvnc >/dev/null || exit 1
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/nodesktop-slim-start"]
