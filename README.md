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
docker build --target production --tag nodesktop:local .
NODEDESKTOP_IMAGE=nodesktop:local ./run_local.sh
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

The local launcher is intentionally isolated: it creates named Docker volumes
for the password and desktop profile, publishes only loopback, and does not
mount the host home or root filesystem. The default local account is
`nodesktop`; the password is selected interactively or read from
`NODEDESKTOP_PASSWORD_FILE`.

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

To use a registry image instead of building locally, set `NODEDESKTOP_IMAGE`
in the Compose environment and keep the password in the secret file. Never
put credentials directly in `compose.yaml`, a shell command, or a committed
environment file.

## TrueNAS and other container platforms

Nodesktop can be installed as a custom TrueNAS application or equivalent
container workload. Keep the application configuration generic and provide
storage mappings through the platform UI or manifest:

- `VNC_RESOLUTION`: `<width>x<height>` (for example, `1680x1050`)
- `NODESKTOP_UI_SCALE`: `100` or `125`
- `VNC_USER`: the desktop account exposed by the platform
- `VNC_PASSWORD_FILE`: a read-only secret-file path
- `HOME`: the writable profile mount used by the desktop account

Map only the directories the operator intends to expose, such as a media
directory to `/mnt/Media` or a downloads directory to `/mnt/Downloads`.
Prefer an unprivileged container, read-only root, dropped capabilities, and
platform-managed secrets. The legacy `VNC_PW` environment variable is retained
only for migration of older manifests; secret files are the recommended mode.
Likewise, host `/etc/passwd`, `/etc/group`, `/etc/shadow`, broad privileges, and
host-root mounts are compatibility features for legacy deployments and should
not be enabled for a new installation.

The application should expose the HTTPS/KasmVNC port only through the
platform's authenticated portal or a private network. Do not commit a real
hostname, username, password, dataset path, or personal mount layout to a
manifest or this repository.

## Images and validation

Build the smaller core or complete image independently:

```bash
docker build --target core --tag nodesktop:local-core .
docker build --target full --tag nodesktop:local-full .
```

After starting a container, run `./tests/static.sh`,
`./tests/smoke.sh <container-name>`, and
`./tests/functional.sh <container-name>` to verify source/config integrity,
installed versions, process health, visual defaults, tool launchers, and runtime
security settings.

For a complete local verification, run the checks in this order:

```bash
./tests/static.sh
./tests/smoke.sh <container-name>
./tests/functional.sh <container-name>
./tests/performance.sh <container-name>
```

The legacy Google Cloud launcher is retained for reference but is not a
supported Nodesktop 3 deployment path; it does not implement this local
hardening model.

Published releases use an immutable version-and-distribution tag such as
`<registry>/<namespace>/nodesktop:3.0.0-trixie`. The shorter version,
distribution, and `latest` tags are convenience aliases; production
deployments should use the immutable tag or its registry digest. The registry
namespace is deployment-specific and is deliberately not hard-coded in this
repository's documentation.
