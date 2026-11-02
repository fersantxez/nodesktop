# AMD64 maintenance release based on the exact image previously deployed on HQ.
FROM fernandosanchez/nodesktop@sha256:97f00d1876719f5eeeb3a77ccb9e00a2bd6548c4d820cbd530adf75ef55d569f
ARG REVISION=working-tree
LABEL org.opencontainers.image.version="3.0.7-multimedia" \
      org.opencontainers.image.revision="${REVISION}"
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends pulseaudio pulseaudio-utils python3-aiohttp vlc \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
COPY config/multimedia-mimeapps.list /tmp/multimedia-mimeapps.list
RUN cat /tmp/multimedia-mimeapps.list >> /etc/xdg/mimeapps.list \
 && rm /tmp/multimedia-mimeapps.list
COPY scripts/nodesktop-entrypoint.sh /usr/local/bin/nodesktop-entrypoint
COPY scripts/nodesktop-audio-proxy.py /usr/local/bin/nodesktop-audio-proxy.py
COPY scripts/patch-kasmvnc.sh /usr/local/bin/patch-kasmvnc.sh
COPY assets/kasmvnc/nodesktop-audio.js /usr/local/share/nodesktop/kasm-assets/nodesktop-audio.js
RUN chmod 0755 /usr/local/bin/nodesktop-entrypoint /usr/local/bin/patch-kasmvnc.sh \
 && install -m 0644 /usr/local/share/nodesktop/kasm-assets/nodesktop-audio.js /usr/local/share/nodesktop/kasmvnc-www/nodesktop-audio.js \
 && grep -Fq '</body>' /usr/local/share/nodesktop/kasmvnc-www/index.html \
 && sed -i 's#</body>#<script defer src="./nodesktop-audio.js"></script></body>#' /usr/local/share/nodesktop/kasmvnc-www/index.html
USER nodesktop
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=6 \
  CMD ["bash", "-c", "pgrep --exact Xvnc >/dev/null && pgrep --exact pulseaudio >/dev/null && pgrep -f '^python3 /usr/local/bin/nodesktop-audio-proxy.py' >/dev/null"]
