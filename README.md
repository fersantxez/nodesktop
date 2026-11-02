# Nodesktop Slim

Nodesktop Slim is a minimal browser-accessible Linux desktop. This branch
documents the Slim edition; the repository's default
[`main` branch](https://github.com/fersantxez/nodesktop/tree/main) documents
the full multimedia desktop. The default Docker image,
`fernandosanchez/nodesktop:latest`, includes VLC and streams desktop video and
application audio to the browser. HQ runs the full edition.

## What Slim includes

- Debian, Openbox, KasmVNC, Firefox ESR, Thunar, Mousepad, and xterm.
- Multilingual and emoji fonts, HTTPS browser access, and password protection.
- Published Linux AMD64 and ARM64 images under
  [`fernandosanchez/nodesktop:slim`](https://hub.docker.com/r/fernandosanchez/nodesktop).

Right-click the desktop for the application menu. Slim deliberately omits
desktop audio streaming and VLC; use the [full edition](https://github.com/fersantxez/nodesktop/tree/main)
for audio and video playback in the browser. The versioned Slim image is
`fernandosanchez/nodesktop:slim-0.2.0`.

## Run Slim locally

With Docker installed, set `VNC_PW` to a password of at least 12 characters,
then run:

```bash
docker run -d --name nodesktop-slim -p 127.0.0.1:6901:6901 \
  -e VNC_PW -v nodesktop-slim-home:/home/nodesktop \
  fernandosanchez/nodesktop:slim
```

Open <https://127.0.0.1:6901> and sign in as `nodesktop`. The certificate is
self-signed by default. For access beyond the local machine, use a private
network or an authenticated TLS reverse proxy.

For deployments using secrets instead of an environment variable, mount a
readable password file at `/run/secrets/vnc_password`, or set
`VNC_PASSWORD_FILE` to its path. Use a separate home volume for Slim rather
than sharing the full desktop's profile.

## Build and verify

```bash
docker build -f slim/Dockerfile -t nodesktop:slim .
./tests/static.sh
./tests/slim-smoke.sh <running-slim-container>
```

The build definition and session files are in [`slim/`](slim/); the smoke test
checks the desktop processes, applications, fonts, authentication, and HTTPS.
