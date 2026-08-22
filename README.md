# Nodesktop 3

Nodesktop is a fast, browser-accessible Debian desktop that runs in a hardened
Docker container. The current design uses Debian 13.6, XFCE 4.20, and KasmVNC
1.5.0 with mandatory TLS and modern video/rectangle encoding.

The interface keeps the established dark-green identity and the selectable
Turrell background, while its new default is an original low-bandwidth forest
grid wallpaper. The compact Orchis Dark Green base uses near-black, forest,
moss-olive, sage, warm white, and restrained gold. Inter Variable is the UI
face, Newsreader is used for window titles, and JetBrains Mono is used in code
and terminals. A small Nodesktop Forest overlay supplies recognizable semantic
place icons while native application icons remain distinct.

Sublime Text, Geany, Terminal, btop, Firefox, and GTK4/libadwaita applications
receive supported dark adapters. Sublime inherits its native layout and changes
only presentation. Papers and other libadwaita tools use dark mode with a green
accent. Bash-it remains installed and the default user starts with its `zork`
theme.

## What is included

The `full` image adds current desktop tools to the lightweight `core` image:

- Firefox 154.0
- Sublime Text 4200 and Geany 2.0
- FileZilla 3.68.1 and Transmission 4.1.3
- Nicotine+ 3.3.10
- Papers 48.3, 7-Zip 25.01, and btop 1.4.7
- Rclone 1.75.0 (the lightweight replacement for the abandoned ODrive client)
- Bash-it 3.2.0
- Tor Browser 15.0.20 on AMD64
- Tor 0.4.9.11 with an isolated Firefox proxy profile on ARM64, where the Tor
  Project does not publish an official Linux Tor Browser bundle

Versions are explicit build arguments in the `Dockerfile`, and every downloaded
archive is checked against a pinned digest.

Firefox enterprise policy disables telemetry, studies, promotional messaging,
and in-browser self-updates. Browser security updates are delivered by rebuilding
the immutable image at the pinned Firefox version. Firefox may still show its
Terms of Use on a new profile; Nodesktop does not accept legal terms for users.

## Run locally

Docker Desktop or Colima is required. Build and start the complete image:

```bash
docker build --target full --tag nodesktop:3.0.0-full .
./run_local.sh
```

The launcher asks for a password of at least 12 characters without displaying
it, stores it in a dedicated read-only Docker volume, and opens only the loopback
interface. Visit <https://127.0.0.1:6901> and sign in as `nodesktop`. A browser
warning is expected because the image uses a locally generated self-signed TLS
certificate.

Non-interactive launch is supported without putting the password in the command
line or container environment:

```bash
NODEDESKTOP_PASSWORD_FILE=/secure/path/password ./run_local.sh my-desktop
```

Optional settings are `NODEDESKTOP_IMAGE`, `NODEDESKTOP_PORT`,
`NODEDESKTOP_RESOLUTION`, and `NODEDESKTOP_UI_SCALE` (`100` or `125`).

## Runtime security

The supported launcher and `compose.yaml` run as UID/GID 1000 with all Linux
capabilities dropped, `no-new-privileges`, a read-only root filesystem, isolated
temporary filesystems, and no host filesystem mounts. Only HTTPS/KasmVNC on
`127.0.0.1:6901` is published; raw VNC is not exposed. The desktop user has no
`sudo` access.

To expose this beyond the laptop, put an authenticated TLS reverse proxy or VPN
in front of it. Do not publish port 6901 directly to the internet.

## Compose

Create `.secrets/vnc_password` containing a 12+ character password, then run:

```bash
docker compose up --build --detach
```

The `.secrets` directory is ignored by Git. `compose.yaml` uses the same
hardened runtime defaults as the launcher.

## Images and validation

Build the smaller core or complete image independently:

```bash
docker build --target core --tag nodesktop:3.0.0-core .
docker build --target full --tag nodesktop:3.0.0-full .
```

After starting a container, run `./tests/static.sh`,
`./tests/smoke.sh <container-name>`, and
`./tests/functional.sh <container-name>` to verify source/config integrity,
installed versions, process health, visual defaults, tool launchers, and runtime
security settings.

The legacy Google Cloud launcher is retained for reference but is not a
supported Nodesktop 3 deployment path; it does not implement this local
hardening model.

Published releases use an immutable version-and-distribution tag such as
`fernandosanchez/nodesktop:3.0.0-trixie`. The shorter `3.0.0`, `trixie`, and
`latest` tags are convenience aliases; production deployments must use the
immutable tag or its registry digest.
