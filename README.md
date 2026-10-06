# Nodesktop

Nodesktop is a browser-accessible Debian desktop distributed as a Docker image.
It combines XFCE, KasmVNC, and a practical set of desktop and terminal tools
in a reproducible, isolated runtime.

## What it provides

- Debian 13.6, XFCE 4.20, and KasmVNC 1.5.0
- HTTPS desktop access on port `6901` (HTTP redirects to HTTPS)
- AMD64 and ARM64 builds
- `core` and `full` image targets
- Pinned application versions and checksums for downloaded archives
- A read-only root filesystem, dropped capabilities, and no host filesystem
  mounts in the supported local launchers

The `full` image includes Firefox, Sublime Text, Geany, FileZilla,
Transmission, Nicotine+, Papers, btop, Xarchiver, 7-Zip, Rclone, Tor, Bash-it,
and the Tor Browser bundle on AMD64. Xarchiver is integrated with Thunar, so
RAR, ZIP, 7z and TAR archives open or extract from the file manager; RAR
extraction uses Debian's UnRAR backend. The exact versions are defined in
`Dockerfile`.

## Desktop appearance

The default desktop uses an Orchis Dark Green theme: near-black, forest, dark
olive, sage, warm white, and restrained gold. It includes a lightweight forest
wallpaper and an alternative Turrell background. Inter Variable is used for
interface text, Newsreader for window titles, and JetBrains Mono for terminals
and code.

Theme settings are supplied for Sublime Text, Geany, XFCE Terminal, btop,
Firefox, and GTK4/libadwaita applications. They adjust presentation without
replacing native application layouts. The custom icon theme is limited to
desktop places and panel controls; application icons remain native. Bash-it is
included in the `full` image and uses the `zork` theme.

## Run locally

Requirements: Docker Desktop, Docker Engine, or a compatible Docker runtime.

```bash
docker build --target production --tag nodesktop:local .
NODEDESKTOP_IMAGE=nodesktop:local ./run_local.sh
```

The launcher asks for a password without displaying it, stores the password and
desktop profile in named Docker volumes, binds the web port to loopback, and
runs the desktop as the unprivileged `nodesktop` user.

Open <https://127.0.0.1:6901> and sign in as `nodesktop`. A certificate warning
is expected during local development because the image creates a self-signed
certificate. Use a trusted TLS reverse proxy when exposing the service beyond
the local machine.

For unattended startup, keep the password in a protected file:

```bash
NODEDESKTOP_PASSWORD_FILE=/path/to/vnc_password ./run_local.sh my-desktop
```

Useful launcher variables are `NODEDESKTOP_IMAGE`, `NODEDESKTOP_PORT`,
`NODEDESKTOP_RESOLUTION`, and `NODEDESKTOP_UI_SCALE` (`100` or `125`).

## Compose

Create a local secret and start the complete image:

```bash
mkdir -p .secrets
umask 077
printf '%s\n' 'choose-a-long-password' > .secrets/vnc_password
docker compose up --build --detach
```

The supplied `compose.yaml` persists `/home/nodesktop` in a named volume,
publishes port `6901` only on loopback, and applies the same runtime
restrictions as the local launcher. Do not commit passwords, private keys,
host paths, or credential-bearing environment files.

## Image targets

```bash
docker build --target core --tag nodesktop:local-core .
docker build --target full --tag nodesktop:local-full .
```

`core` is the smaller desktop image. `full` adds the application set listed
above. `production` is the default runtime target and is based on `full`.

## Verification

Run the checks from the repository root:

```bash
./tests/static.sh
./tests/smoke.sh <container-name>
./tests/functional.sh <container-name>
./tests/performance.sh <image> <secret-volume>
./tests/encoding.sh <container-name>
docker exec -i <container-name> python3 - < tests/xvnc-cpu.py
```

The suite checks source files, generated assets, Dockerfile syntax, image
health, installed versions, desktop settings, theme assets, launchers, and
runtime restrictions.

## Desktop CPU policy

The default KasmVNC profile sends changed image regions, caps updates at 15 FPS,
uses two rectangle compression threads, gives WebP a zero-time budget before
JPEG fallback, and disables full-frame video streaming. Server settings take
precedence over saved browser presets. This keeps terminals, file browsing, and archive extraction inexpensive
while retaining the existing image quality. XFCE compositing is also disabled.

On HQ, switching a connected 1680×906 desktop from software H.265 to image
encoding reduced an observed ten-second Xvnc CPU sample from 60.71% to 1.90%
of one core. This is a workload-specific measurement, not a CPU limit or a
guarantee for video playback. Recheck with `tests/xvnc-cpu.py` while connected
and under the same workload; the cold-start test does not measure encoding CPU.

For a deployment dedicated to video, explicitly configure and benchmark a
hardware encoder with its render device available before enabling streaming.
Do not enable automatic software H.265 selection on a shared NAS by default.
KasmVNC settings are in `config/kasmvnc.yaml`; server-policy changes take effect
when the desktop session restarts.

The AMD64 `3.0.6-cpu-saver` maintenance release uses
`releases/3.0.6-cpu-saver.Dockerfile` to apply this configuration to the pinned
`3.0.5-dank-neon` image without updating application packages. Publish both the
version tag and `latest`; verify their registry digests match before recreating
HQ. Rollback is the previous version tag.

## Security notes

The local launchers are intentionally isolated and do not mount the host home
or root filesystem. Port `6901` carries only the HTTPS web desktop and its
TLS-protected WebSocket connection; raw VNC is not exposed. For remote access,
use a private network or an authenticated TLS reverse proxy instead of
publishing the port directly to the internet.

Use immutable image tags or registry digests for repeatable deployments. Update
the version argument and checksum together in `Dockerfile`, then run the full
verification suite before publishing a release.
