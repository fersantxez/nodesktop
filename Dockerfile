# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=13.6-slim
ARG RCLONE_VERSION=1.75.0

FROM --platform=$BUILDPLATFORM golang:1.26.6-alpine3.24@sha256:3889b425f035be855a72fb4755265311293b6d414521f0a519d819df32222d83 AS rclone-builder

ARG TARGETARCH
ARG RCLONE_VERSION
ARG RCLONE_COMMIT=9ee9d0a0cafd5e5fe3b271d2280b090ab6e64048
ARG RCLONE_SOURCE_SHA256=5798e275444d1d2405b529144203786fc1da9698b60bb86299f78afbb182c691

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk add --no-cache curl \
 && source_archive="rclone-${RCLONE_COMMIT}.tar.gz" \
 && curl --fail --location --retry 5 --output "/tmp/${source_archive}" \
      "https://github.com/rclone/rclone/archive/${RCLONE_COMMIT}.tar.gz" \
 && echo "${RCLONE_SOURCE_SHA256}  /tmp/${source_archive}" | sha256sum -c \
 && mkdir -p /src/rclone /out \
 && tar --extract --gzip --strip-components=1 --file "/tmp/${source_archive}" --directory /src/rclone \
 && cd /src/rclone \
 && go get golang.org/x/image@v0.45.0 \
 && CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
      go build -buildvcs=false -trimpath \
      -ldflags="-s -w -X github.com/rclone/rclone/fs.Version=v${RCLONE_VERSION}" \
      -o /out/rclone .

FROM debian:${DEBIAN_VERSION}@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258 AS visual-assets

ARG ORCHIS_VERSION=2026-07-07
ARG ORCHIS_SHA256=a977ecfeb13a7e68a40393dfed1b578864dfb968ff21b9eceda83ffbef9e460f

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      libgtk-3-bin \
      sassc \
 && orchis_archive="orchis-${ORCHIS_VERSION}.tar.gz" \
 && curl --fail --location --retry 5 --output "/tmp/${orchis_archive}" \
      "https://github.com/vinceliuice/Orchis-theme/archive/refs/tags/${ORCHIS_VERSION}.tar.gz" \
 && echo "${ORCHIS_SHA256}  /tmp/${orchis_archive}" | sha256sum --check --strict \
 && mkdir -p /tmp/orchis /out/themes \
 && tar --extract --gzip --strip-components=1 --file "/tmp/${orchis_archive}" --directory /tmp/orchis \
 && /tmp/orchis/install.sh \
      --dest /out/themes \
      --name Nodesktop-Orchis \
      --theme green \
      --color dark \
      --size compact \
      --tweaks primary

FROM debian:${DEBIAN_VERSION}@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258 AS desktop-base

ARG TARGETARCH
ARG KASMVNC_VERSION=1.5.0
ARG KASMVNC_SHA256_AMD64=80b241de7dfe53bba2b7e1cc5ac8c5246d72271efa16be2d4f76607f30fab1c4
ARG KASMVNC_SHA256_ARM64=fbb11589958a2acccd2d67f67944be79ac1e8e3a1d6172c0e6db6dc59e55a919
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG NEWSREADER_COMMIT=cfcb4f7af0e52c25e8df2a2431814c8e5fe2e155
ARG NEWSREADER_SHA256=8a08d13f8a6c0d51be379a60af84f945f65369a67e509ee3c3bdcc421254d7c1
ARG NEWSREADER_OFL_SHA256=fdfad38143ec470553cae82a1e45320bdd1b9ec70415d37bd0171051d8a4ded8
ARG VERSION=3.0.0
ARG REVISION=unknown
ARG CREATED=unknown

LABEL org.opencontainers.image.title="Nodesktop" \
      org.opencontainers.image.description="Fast, secure browser-accessible Debian desktop" \
      org.opencontainers.image.source="https://github.com/fersantxez/nodesktop" \
      org.opencontainers.image.base.name="docker.io/library/debian:13.6-slim" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.created="${CREATED}" \
      org.opencontainers.image.licenses="NOASSERTION"

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    HOME=/home/nodesktop \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NO_AT_BRIDGE=1 \
    VNC_DISPLAY=:1 \
    VNC_PORT=6901 \
    VNC_BACKEND_PORT=6902 \
    VNC_RESOLUTION=1440x900 \
    VNC_USER=nodesktop \
    XDG_RUNTIME_DIR=/tmp/runtime-nodesktop

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dbus-x11 \
      desktop-file-utils \
      fonts-dejavu-core \
      fonts-inter-variable \
      fonts-jetbrains-mono \
      fonts-liberation \
      fonts-wqy-zenhei \
      gtk2-engines-murrine \
      librsvg2-common \
      libnss3 \
      libavformat61 \
      libglib2.0-bin \
      libswscale8 \
      libva2 \
      procps \
      python3-minimal \
      ssl-cert \
      tini \
      thunar \
      tumbler \
      x11-xserver-utils \
      xdg-utils \
      xfce4-appfinder \
      xfce4-netload-plugin \
      xfce4-panel \
      xfce4-session \
      xfce4-settings \
      xfce4-systemload-plugin \
      xfce4-terminal \
      xfce4-whiskermenu-plugin \
      xfdesktop4 \
      xfwm4 \
 && case "${TARGETARCH}" in \
      amd64) kasm_arch=amd64; kasm_sha="${KASMVNC_SHA256_AMD64}" ;; \
      arm64) kasm_arch=arm64; kasm_sha="${KASMVNC_SHA256_ARM64}" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && kasm_package="kasmvncserver_trixie_${KASMVNC_VERSION}_${kasm_arch}.deb" \
 && curl --fail --location --retry 5 --output "/tmp/${kasm_package}" \
      "https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/${kasm_package}" \
 && echo "${kasm_sha}  /tmp/${kasm_package}" | sha256sum --check --strict \
 && apt-get install -y --no-install-recommends "/tmp/${kasm_package}" \
 && install -d /usr/local/share/fonts/newsreader /usr/local/share/licenses/newsreader \
 && curl --fail --location --retry 5 --output /usr/local/share/fonts/newsreader/Newsreader-Variable.ttf \
      "https://raw.githubusercontent.com/productiontype/Newsreader/${NEWSREADER_COMMIT}/fonts/variable/ttf/Newsreader%5Bopsz%2Cwght%5D.ttf" \
 && echo "${NEWSREADER_SHA256}  /usr/local/share/fonts/newsreader/Newsreader-Variable.ttf" | sha256sum --check --strict \
 && curl --fail --location --retry 5 --output /usr/local/share/licenses/newsreader/OFL.txt \
      "https://raw.githubusercontent.com/productiontype/Newsreader/${NEWSREADER_COMMIT}/OFL.txt" \
 && echo "${NEWSREADER_OFL_SHA256}  /usr/local/share/licenses/newsreader/OFL.txt" | sha256sum --check --strict \
 && rm -f "/tmp/${kasm_package}" \
 && groupadd --gid "${GROUP_ID}" nodesktop \
 && useradd --uid "${USER_ID}" --gid "${GROUP_ID}" --create-home --shell /bin/bash nodesktop \
 && usermod --append --groups ssl-cert nodesktop \
 && install -d -o nodesktop -g nodesktop /home/nodesktop/.config/xfce4 \
 && apt-get clean \
 && find /usr/share/doc -type f ! -name copyright -delete \
 && find /usr/share/doc -depth -type d -empty -delete \
 && find /usr/share/themes -mindepth 1 -maxdepth 1 -type d \
      ! -name 'Default' ! -name 'Default-hdpi' ! -name 'Default-xhdpi' -exec rm -rf -- {} + \
 && rm -rf /usr/share/backgrounds/* \
 && rm -rf /usr/share/man/* /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

COPY config/kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY config/glib/99_nodesktop.gschema.override /usr/share/glib-2.0/schemas/99_nodesktop.gschema.override
COPY --from=visual-assets /out/themes/ /usr/share/themes/
COPY assets/icons/nodesktop-forest/ /usr/share/icons/Nodesktop-Forest/
COPY assets/icons/nodesktop-panel/index.theme /usr/share/icons/Nodesktop-Forest/index.theme
COPY assets/icons/nodesktop-panel/scalable/ /usr/share/icons/Nodesktop-Forest/scalable/
COPY assets/wallpapers/turrell.jpg /usr/share/wallpapers/turrell.jpg
COPY assets/wallpapers/nodesktop-grid.svg /usr/share/wallpapers/nodesktop-grid.svg
COPY config/xfce4/ /usr/local/share/nodesktop/xfce4/
COPY config/generated/ /usr/local/share/nodesktop/generated/
COPY config/sublime/Packages/User/ /usr/local/share/nodesktop/sublime/
COPY config/geany/ /usr/local/share/nodesktop/geany/
COPY config/btop/ /usr/local/share/nodesktop/btop/
COPY config/bashrc /usr/local/share/nodesktop/bashrc
COPY assets/kasmvnc/nodesktop.css config/generated/nodesktop-web-tokens.css assets/brand/nodesktop-mark.svg /usr/local/share/nodesktop/kasm-assets/
COPY scripts/migrate-style.py scripts/nodesktop-style-rollback scripts/patch-kasmvnc.sh /usr/local/bin/

RUN cp -R /usr/local/share/nodesktop/xfce4/. /home/nodesktop/.config/xfce4/ \
 && cd /usr/share/icons/Nodesktop-Forest/scalable/places \
 && ln -s folder.svg folder-open.svg \
 && ln -s folder.svg folder-remote.svg \
 && ln -s folder-documents.svg folder-templates.svg \
 && ln -s folder-network.svg network-workgroup.svg \
 && ln -s folder-network.svg network-server.svg \
 && ln -s folder-videos.svg folder-video.svg \
 && ln -s user-home.svg go-home.svg \
 && ln -s user-trash.svg user-trash-full.svg \
 && cd /usr/share/icons/Nodesktop-Forest/scalable/devices \
 && ln -s drive-harddisk.svg drive-removable-media.svg \
 && install -d /etc/xdg/gtk-3.0 \
 && install -m 0644 /usr/local/share/nodesktop/generated/gtk-nodesktop.css /etc/xdg/gtk-3.0/gtk.css \
 && install -m 0644 /usr/local/share/nodesktop/kasm-assets/nodesktop-mark.svg /usr/share/icons/Nodesktop-Forest/scalable/apps/nodesktop-mark.svg \
 && ln -s nodesktop-mark.svg /usr/share/icons/Nodesktop-Forest/scalable/apps/org.xfce.panel.whiskermenu.svg \
 && /usr/local/bin/patch-kasmvnc.sh /usr/share/kasmvnc/www /usr/local/share/nodesktop/kasmvnc-www /usr/local/share/nodesktop/kasm-assets \
 && glib-compile-schemas /usr/share/glib-2.0/schemas \
 && fc-cache -f \
 && gtk-update-icon-cache --force /usr/share/icons/Nodesktop-Forest \
 && chown -R nodesktop:nodesktop /home/nodesktop \
 && chmod 0755 /usr/local/bin/migrate-style.py /usr/local/bin/nodesktop-style-rollback \
 && chmod 0644 /usr/share/wallpapers/turrell.jpg /usr/share/wallpapers/nodesktop-grid.svg /usr/local/share/fonts/newsreader/*.ttf

FROM desktop-base AS core-filesystem

ARG TARGETARCH
ARG FIREFOX_VERSION=154.0
ARG FIREFOX_SHA512_AMD64=0e57c27d947a78f88b5d9d3407e67b67316a41b82f747cddcee15f71f5e80691fc9be488f98e8bb6cca183739f953e2e09dc5429ec030fbe4b8060886dafdf62
ARG FIREFOX_SHA512_ARM64=72fd961d7dba59ed9205f282ad2daeecc15bbd773b3f4d5ba8576c85114c68bdce8cd0472e16ec74bc5c9b502bd48f87cdc33c059b82442d0fc0a5732ad13354
ARG BTOP_VERSION=1.4.7
ARG BTOP_SHA256_AMD64=5099054dd6a101bd12eb6ff3702a9a6a3f57aaa27923a0da478ae5b517faf335
ARG BTOP_SHA256_ARM64=6270de0ef4c84cf0eea61cb148b3ad9ae91a11e9c3309867ffc6b3751024c252

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      7zip \
      geany \
      libasound2t64 \
      libdbus-glib-1-2 \
      libgtk-3-0t64 \
      papers \
      xz-utils \
 && case "${TARGETARCH}" in \
      amd64) firefox_arch=x86_64; firefox_sha="${FIREFOX_SHA512_AMD64}"; btop_arch=x86_64; btop_sha="${BTOP_SHA256_AMD64}" ;; \
      arm64) firefox_arch=aarch64; firefox_sha="${FIREFOX_SHA512_ARM64}"; btop_arch=aarch64; btop_sha="${BTOP_SHA256_ARM64}" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && firefox_archive="firefox-${FIREFOX_VERSION}.tar.xz" \
 && curl --fail --location --retry 5 --output "/tmp/${firefox_archive}" \
      "https://archive.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-${firefox_arch}/en-US/${firefox_archive}" \
 && echo "${firefox_sha}  /tmp/${firefox_archive}" | sha512sum --check --strict \
 && tar --extract --xz --file "/tmp/${firefox_archive}" --directory /opt \
 && rm -f \
      /opt/firefox/crashhelper \
      /opt/firefox/crashreporter \
      /opt/firefox/crashreporter.ini \
      /opt/firefox/pingsender \
      /opt/firefox/updater \
 && ln -s /opt/firefox/firefox /usr/local/bin/firefox \
 && btop_archive="btop-${btop_arch}-unknown-linux-musl.tar.gz" \
 && curl --fail --location --retry 5 --output "/tmp/${btop_archive}" \
      "https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/${btop_archive}" \
 && echo "${btop_sha}  /tmp/${btop_archive}" | sha256sum --check --strict \
 && tar --extract --gzip --file "/tmp/${btop_archive}" --directory /tmp \
 && install -m 0755 /tmp/btop/bin/btop /usr/local/bin/btop \
 && install -d /usr/local/share/btop \
 && cp -R /tmp/btop/themes /tmp/btop/Img /usr/local/share/btop/ \
 && install -m 0644 /usr/local/share/nodesktop/generated/nodesktop-btop.theme \
      /usr/local/share/btop/themes/nodesktop.theme \
 && apt-get purge -y --auto-remove xz-utils \
 && apt-get clean \
 && find /usr/share/doc -type f ! -name copyright -delete \
 && find /usr/share/doc -depth -type d -empty -delete \
 && find /usr/share/help -mindepth 1 -maxdepth 1 -type d \
      ! -name C ! -name en ! -name es -exec rm -rf -- {} + \
 && rm -rf /usr/share/gtk-doc/* \
 && rm -rf /usr/share/man/* /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

COPY config/applications/firefox.desktop /usr/share/applications/firefox.desktop

FROM core-filesystem AS core

COPY scripts/nodesktop-entrypoint.sh /usr/local/bin/nodesktop-entrypoint
COPY scripts/nodesktop-http-redirect.py /usr/local/bin/nodesktop-http-redirect.py
COPY config/firefox/policies.json /opt/firefox/distribution/policies.json
COPY config/bashrc /home/nodesktop/.bashrc

RUN chmod 0755 /usr/local/bin/nodesktop-entrypoint /usr/local/bin/nodesktop-http-redirect.py \
 && chown nodesktop:nodesktop /home/nodesktop/.bashrc

USER nodesktop
WORKDIR /home/nodesktop

EXPOSE 6901

VOLUME ["/home/nodesktop"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=6 \
  CMD ["pgrep", "--exact", "Xvnc"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/nodesktop-entrypoint"]
CMD []

FROM core-filesystem AS full

ARG TARGETARCH
ARG RCLONE_VERSION
ARG TOR_BROWSER_VERSION=15.0.20
ARG TOR_BROWSER_SHA256_AMD64=d4302633d6059d2dad94e2c883b31141dc7b3daa2bfa5aabb0fd29dda18d22e9
ARG BASH_IT_VERSION=3.2.0
ARG BASH_IT_SHA256=e6fbe4efee5f4f63e8e5788f957d66df541839d066d078f6bb8f07c7213114a5

USER root

COPY --from=rclone-builder /out/rclone /usr/local/bin/rclone

RUN echo "deb https://deb.debian.org/debian trixie-backports main" > /etc/apt/sources.list.d/trixie-backports.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      filezilla \
      gnupg \
      nicotine \
      tor \
      xz-utils \
 && apt-get install -y --no-install-recommends --target-release trixie-backports transmission-gtk \
 && curl --fail --location --retry 5 https://download.sublimetext.com/sublimehq-pub.gpg \
      | gpg --dearmor --yes --output /usr/share/keyrings/sublimehq-archive.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" \
      > /etc/apt/sources.list.d/sublime-text.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends sublime-text=4200 \
 && install -d -o nodesktop -g nodesktop \
      /home/nodesktop/Applications \
      /home/nodesktop/.mozilla/nodesktop-tor \
 && if [[ "${TARGETARCH}" == amd64 ]]; then \
      tor_archive="tor-browser-linux-x86_64-${TOR_BROWSER_VERSION}.tar.xz"; \
      curl --fail --location --retry 5 --output "/tmp/${tor_archive}" \
        "https://dist.torproject.org/torbrowser/${TOR_BROWSER_VERSION}/${tor_archive}"; \
      echo "${TOR_BROWSER_SHA256_AMD64}  /tmp/${tor_archive}" | sha256sum --check --strict; \
      tar --extract --xz --file "/tmp/${tor_archive}" --directory /home/nodesktop/Applications; \
    fi \
 && chown -R nodesktop:nodesktop /home/nodesktop/Applications \
 && bash_it_archive="bash-it-${BASH_IT_VERSION}.tar.gz" \
 && curl --fail --location --retry 5 --output "/tmp/${bash_it_archive}" \
      "https://github.com/Bash-it/bash-it/archive/refs/tags/v${BASH_IT_VERSION}.tar.gz" \
 && echo "${BASH_IT_SHA256}  /tmp/${bash_it_archive}" | sha256sum --check --strict \
 && tar --extract --gzip --file "/tmp/${bash_it_archive}" --directory /opt \
 && rm -rf \
      "/opt/bash-it-${BASH_IT_VERSION}/.github" \
      "/opt/bash-it-${BASH_IT_VERSION}/docs" \
      "/opt/bash-it-${BASH_IT_VERSION}/test" \
      "/opt/bash-it-${BASH_IT_VERSION}/test_lib" \
 && ln -s "/opt/bash-it-${BASH_IT_VERSION}" /opt/bash-it \
 && apt-get purge -y --auto-remove gnupg xz-utils \
 && apt-get clean \
 && find /usr/share/doc -type f ! -name copyright -delete \
 && find /usr/share/doc -depth -type d -empty -delete \
 && rm -rf /usr/share/man/* /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

COPY config/applications/rclone.desktop /usr/share/applications/rclone.desktop
COPY config/applications/tor-browser.desktop /usr/share/applications/tor-browser.desktop
COPY config/bashrc /home/nodesktop/.bashrc
COPY config/firefox/policies.json /opt/firefox/distribution/policies.json
COPY config/tor-user.js /home/nodesktop/.mozilla/nodesktop-tor/user.js
COPY scripts/nodesktop-entrypoint.sh /usr/local/bin/nodesktop-entrypoint
COPY scripts/nodesktop-http-redirect.py /usr/local/bin/nodesktop-http-redirect.py
COPY scripts/nodesktop-tor-browser.sh /usr/local/bin/nodesktop-tor-browser

RUN chmod 0755 /usr/local/bin/nodesktop-entrypoint /usr/local/bin/nodesktop-http-redirect.py /usr/local/bin/nodesktop-tor-browser \
 && chown -R nodesktop:nodesktop /home/nodesktop/.bashrc /home/nodesktop/.mozilla

# Overlay the two XFCE panel glyphs after the application layers so small visual
# refinements do not invalidate the much larger package-install layers.
COPY assets/icons/nodesktop-panel/index.theme /usr/share/icons/Nodesktop-Forest/index.theme
COPY assets/icons/nodesktop-panel/scalable/ /usr/share/icons/Nodesktop-Forest/scalable/
RUN gtk-update-icon-cache --force /usr/share/icons/Nodesktop-Forest

FROM full AS full-amd64
RUN test "$(dpkg --print-architecture)" = amd64

FROM full AS full-arm64
RUN test "$(dpkg --print-architecture)" = arm64

FROM full AS production

USER nodesktop
WORKDIR /home/nodesktop

EXPOSE 6901

VOLUME ["/home/nodesktop"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=6 \
  CMD ["pgrep", "--exact", "Xvnc"]

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/nodesktop-entrypoint"]
CMD []
