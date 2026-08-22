# Nodesktop `lookupdate` research and implementation plan

Status: planned on 2026-08-21 after Nodesktop 2.0.0 was published and deployed to HQ.

This branch is a visual and performance redesign. It does not replace the secure runtime work in 2.0.0, and it does not remove any function from the `full` image. The design is inspired by the visual grammar of [opencloud.org](https://opencloud.org/), but it will not copy OpenCloud/DFINITY branding or proprietary website assets.

## Executive decision

Keep XFCE 4.20 and KasmVNC. Re-skin and simplify the desktop around a compact, original “OpenCloud editorial dark” system: near-black carbon surfaces, forest and olive greens, warm white text, and gold used only as a small status accent. Use Inter for the interface, Newsreader for selected editorial moments, and JetBrains Mono for terminals and telemetry.

Replace the current two-theme Tela payload with a very small Nodesktop overlay icon theme that inherits Adwaita and hicolor. The overlay will contain original green folder/place icons, curated Lucide actions/status glyphs, and an original Nodesktop menu mark. Keep native application icons so Firefox, FileZilla, Transmission, and the other tools remain immediately recognizable.

Adopt Whisker Menu as the primary launcher, retain App Finder as a keyboard fallback, keep the two small XFCE panel monitors, and expose `btop` as the detailed on-demand monitor. Do not add Conky, GNOME Shell, a dock compositor, Electron launchers, or a resident dashboard.

Ship several build targets, but keep `full-amd64` as the HQ image. `core` and optional functional bundles make the project lighter for other deployments without taking anything away from HQ.

## Research findings

### What makes the reference site feel polished

The live site and its shipped CSS were inspected at 1440 × 1200. Its visual character comes from restraint rather than effects:

- an off-white canvas with a faint 24 px technical grid and very light noise;
- small monospace section labels with wide letter spacing;
- large Newsreader serif headings, with italics used as emphasis;
- Inter for navigation and body copy, and JetBrains Mono for data labels;
- one-pixel rules, 2–6 px radii, almost no shadows, and generous negative space;
- a dark ink foreground and one muted teal-green accent;
- numbered sections, terse labels, and small engineering marks such as `§`, dots, and crosses.

The site currently declares these relevant colors:

| Role | Reference value |
| --- | --- |
| canvas | `#FAF9F5` |
| ink | `#0F172A` |
| accent | `#0B5E5C` |
| warm muted text | `#6F6960` |
| cream section | `#F3F1EA` |
| rule | `#E2E5EA` |

Nodesktop should borrow the hierarchy, grid, restraint, and type roles—not these exact brand colors or the OpenCloud mark.

### Reuse and licensing boundary

- Inter, Newsreader, and JetBrains Mono are available under the SIL Open Font License 1.1. Their upstream license files must ship beside the fonts.
- Lucide is ISC licensed, with a subset inherited from Feather under MIT. Only selected SVGs and the applicable notices will be copied; no JavaScript package is needed at runtime.
- Orchis is GPL-3.0. Nodesktop may continue to build a modified variant as long as the license and source/patch trail are preserved.
- Tela and Tela Circle are GPL-3.0. The circular folder design was rejected in visible testing because generic folders read as ambiguous badges. The final design uses the MIT-licensed Nodesktop Forest overlay, with semantic green place/storage icons and inherited native application icons.
- Roobert is a commercial Displaay typeface. The repository contains the font files but no license evidence. The redesign will remove it from the distributable image unless an appropriate app/game or redistribution license is documented.
- OpenCloud/DFINITY website terms do not provide a general license to reuse their logo, favicon, copy, or site artwork. Those assets must not be packaged. The Nodesktop menu icon and wallpaper will be original.

### Verified version baseline

As of 2026-08-21:

- Debian 13.6 is the current stable Debian point release.
- XFCE 4.20 is the current stable XFCE desktop release.
- KasmVNC 1.5.0 is current and adds newer streaming modes, relative mouse input, environment overrides, and security/compatibility fixes.
- Firefox 154.0, Tor Browser 15.0.20, btop 1.4.7, rclone 1.75.0, and the 2026-07-07 Orchis/Tela releases were current at the time the 2.0.0 image was built.
- “Latest” must mean the newest stable release compatible with Debian stable and the current XFCE ABI. Development ABIs must not be mixed into the production image merely to increase a version number.

Automated update checks are required because this table becomes stale quickly.

## Measured baseline

| Item | Current measurement | Interpretation |
| --- | ---: | --- |
| published full AMD64 | ~693 MB compressed | HQ production image; Tor Browser is the largest architecture-specific payload |
| published full ARM64 | ~494.5 MB compressed | lacks upstream Tor Browser, uses Firefox-through-Tor fallback |
| local core ARM64 | ~420.0 MB compressed | keeps browser, desktop, editor, PDF, archive, and monitoring functions |
| full ARM64 vs core ARM64 | ~74.5 MB compressed | cost of the optional full tools without Tor Browser |
| installed dpkg database | 19.7 MiB / ~2.43 MB gzip | too little benefit for the audit and maintenance loss; retain it |
| two Nodesktop Tela trees | ~68.4 MiB / ~6.1 MB gzip | strong low-risk replacement candidate |
| Lato fonts | 11.6 MiB / ~6.1 MB gzip | not referenced by the desktop configuration |
| Roobert fonts | 3.4 MiB / ~1.4 MB gzip | 13 files; only two faces are configured; licensing evidence absent |
| Bash-it | 4.1 MiB / ~1.34 MB gzip | current config uses only the `clean` theme and disables SCM checks |
| Turrell JPEG | ~1.0 MB | preserve as an optional legacy wallpaper, not the new default |
| installed Debian packages | 529 | package inventory is a feature for security and support, not disposable weight |

The interactive test container used about 250 MiB after launching multiple tools. A fresh-start, no-application benchmark must be captured before implementation; this number is not an idle baseline.

The first current-database Grype scan produced seven fixable High version matches, all in `/usr/local/bin/rclone`: six standard-library matches because the official rclone 1.75.0 binary was built with Go 1.26.5 (the listed fix is Go 1.26.6), plus `GO-2026-6222` because it embeds `golang.org/x/image` 0.44.0 (fixed in 0.45.0). Version matching alone does not prove that rclone reaches each vulnerable symbol, but it is an actionable release blocker. Prefer a newer official rclone build when available; otherwise evaluate a reproducible source build with the fixed toolchain/module, run `govulncheck` for reachability, and repeat the complete rclone functional matrix. Raw scanner totals also include many duplicated, `wont-fix`, or not-yet-fixed NVD matches whose severity can differ from Debian's vendor assessment; they must be triaged, not presented as 1:1 exploitable defects.

## Acceptance objectives

### Functionality

- The `full-amd64` image retains every current desktop tool and is the image deployed to HQ.
- Every launcher opens the intended application, every helper association works, and mounted HQ datasets remain reachable.
- ARM64 limitations are explicit. If upstream Tor Browser still has no Linux ARM64 build, the tested Firefox + local Tor SOCKS fallback remains, with an honest label rather than pretending it is Tor Browser parity.
- Existing user profiles migrate once by a versioned, idempotent style migration. User documents and application state are never erased.

### Visual quality

- No blue folder/place glyph is visible in Thunar, desktop icons, file pickers, bookmarks, or the panel.
- The primary visual range is black/carbon → forest/olive → warm white. Gold is below roughly 5% of visible accent use and never substitutes for warning/error semantics.
- Normal text reaches WCAG AA contrast (4.5:1); large text and non-text controls reach at least 3:1.
- The desktop is coherent at 1440 × 900, HQ’s 1680 × 1050, and 1920 × 1080, at 100% and 125% UI scale.
- Spanish, English, accented Latin, and CJK fallback glyphs are visually tested.
- The KasmVNC sign-in, connection, reconnect, disconnected, and control-drawer surfaces use the same visual system as the desktop without changing authentication or transport behavior.
- Hover, pressed, checked, selected, disabled, focus, destructive, warning, error, success, progress, empty, loading, and offline states are specified and visibly tested wherever the toolkit exposes them.
- Every application in `core` and `full` has a recorded visual ownership decision: themed by the GTK/XFWM system, configured through a supported application preference, deliberately left vendor-native, or exempted for a documented security/compatibility reason.
- Keyboard focus is always visible, state is never conveyed by color alone, and pointer targets are at least 32 px in the remote-desktop shell unless a native dense control cannot be changed safely.

### Performance and weight

Hard gates for the first implementation pass:

- `core-arm64` at or below 405 MB compressed;
- `full-arm64` at or below 480 MB compressed;
- `full-amd64` at or below 680 MB compressed;
- fresh idle memory at or below 200 MiB after two minutes, with no browser or application open;
- fresh idle CPU below 1% averaged over 60 seconds;
- KasmVNC usable desktop in 15 seconds or less on the local laptop in five consecutive cold starts;
- Whisker Menu visible and searchable within 150 ms on the local laptop;
- no visual effect that causes continuous CPU use while the desktop is idle.

These are release gates, not estimates. If a target is missed, the size/performance report must identify the responsible layer or process.

### Security

- Runtime remains non-root and unprivileged; local defaults retain read-only root filesystem, all capabilities dropped, and `no-new-privileges`.
- Passwords remain file-mounted secrets and never appear in image layers, environment variables, manifests, logs, or email.
- No fixable High/Critical match may remain in a shipped artifact unless vendor status and reachability evidence document it as a false positive. Unfixed vendor findings require a documented decision and upstream link.
- Each published multi-architecture image has an SPDX SBOM and max-mode provenance attestation, and is deployed by immutable digest.
- All downloaded archives, fonts, themes, and standalone binaries are version-pinned and checksum-verified.

## Proposed visual system

### Original dark palette

| Token | Value | Use | Contrast note |
| --- | --- | --- | --- |
| `ink` | `#0B0F0C` | desktop and deepest surface | warm white: 16.9:1 |
| `carbon` | `#111612` | terminal and panel | existing Nodesktop base |
| `surface` | `#151C17` | menus, cards, dialogs | body text: 12.35:1 |
| `forest` | `#1F5B3A` | primary selection/button | warm white: 7.03:1 |
| `olive` | `#73875A` | folders, charts, focus secondary | on ink: 4.91:1 |
| `sage` | `#AFC39D` | active data and quiet emphasis | on ink: 10.22:1 |
| `warm-white` | `#F2F0E6` | headings and selected text | avoids cold pure white |
| `body` | `#D7DBD2` | primary UI text | on ink: 13.74:1 |
| `muted` | `#98A193` | labels and disabled text | on ink: 7.22:1 |
| `rule` | `#29342C` | one-pixel separators and grid | intentionally quiet |
| `gold` | `#B79A61` | rare status/section accent | on ink: 7.18:1 |

Errors, warnings, and success states keep distinct semantic colors. They are adjusted to harmonize with the palette but are not recolored green or gold in a way that obscures meaning.

### Typography

- Inter Variable: GTK interface, Thunar, menu, desktop labels, and ordinary panel text.
- Newsreader Variable: XFWM window titles, the optional clock/date treatment, welcome/about content, and wallpaper typography. It should never be used for dense settings dialogs.
- JetBrains Mono Variable: XFCE Terminal, system readings, small technical labels, and code.
- Keep DejaVu/Liberation and WQY Zen Hei as fallbacks so symbol, document, and CJK coverage does not regress.
- Remove Lato, Inconsolata, and Roobert after glyph/fallback tests pass.
- Prefer one variable file per family and subset only the primary Latin faces. Do not subset fallback fonts required for user documents.

### Wallpaper

Create an original SVG wallpaper instead of copying the site background:

- carbon-to-ink radial gradient;
- extremely faint 24 px technical grid;
- one or two broad forest/olive contours echoing the existing Turrell landscape;
- a tiny gold registration mark, never a brand logo;
- no animated filters, blur loops, or high-cost SVG turbulence;
- target below 40 KB, verified in `xfdesktop` through librsvg at all resolutions.

Keep `turrell.jpg` as a selectable legacy option during the branch. Remove it from the final image only after the user explicitly approves the new wallpaper; otherwise it remains at a one-megabyte cost.

### GTK, windows, and panel

- Continue with the latest compatible Orchis dark compact base because it already matches the requested “Orchis dark green” direction and has proven XFWM/GTK coverage.
- Apply a small, reviewable palette patch instead of carrying opaque generated edits.
- Reduce roundness to 4–6 px, use one-pixel rules, remove heavy shadows, and preserve strong focus outlines.
- Keep one top panel and one compact launcher/telemetry panel. Avoid docks that require a compositor or background daemon.
- Use the forest tone for active workspaces and focused controls, olive/sage for graphs, and gold only for the memory/storage secondary series.
- Use opacity only where it does not reduce text contrast; avoid blur/translucency because remote encoding turns it into bandwidth-heavy noise.

### Icons and menu mark

Build `Nodesktop-OpenCloud` as a compact overlay theme:

- original green folder/home/download/document variants in scalable SVG;
- selected Lucide actions/status icons at a consistent 1.75 px optical stroke;
- neutral local glyphs for HQ service categories rather than copied product marks;
- an original Nodesktop “N/network” mark for Whisker Menu, distinct from OpenCloud’s seven-dot logo;
- inherited lookup: `Nodesktop-OpenCloud, Adwaita, hicolor`;
- native application icons remain untouched.

The build must include an icon-resolution test that enumerates every `.desktop` file and key GTK action name, renders them, and fails on missing/broken icons or a known blue folder color.

## Complete visual-surface implementation

The redesign must be implemented as a system with explicit ownership, not as a GTK theme plus a wallpaper. The source tree will have one canonical token set, small adapters for each supported UI technology, and a visual-state manifest that drives capture and approval.

### Canonical design contract

Add `assets/design/tokens.json` as the machine-readable source of truth. It contains only stable visual primitives:

- palette and semantic colors, including foreground/background pairs for every state;
- typography families, weights, sizes, and line heights;
- spacing steps of 4, 8, 12, 16, 24, and 32 px;
- 3 px small-control and 5 px dialog/menu radii;
- one-pixel structural rules and a two-pixel high-contrast focus outline;
- icon sizes of 16, 20, 24, 32, and 48 px;
- 100% and 125% density-profile values for fonts, panels, cursors, and desktop icons.

Semantic state colors are fixed before adapter work begins:

| State | Foreground/icon | Filled action | Required text treatment |
| --- | --- | --- | --- |
| danger | `#EF8B86` | `#7F3434` | warm white on filled action: 7.52:1 |
| warning | `#E0B35E` | `#8A5A12` | warm white on filled action: 5.18:1 |
| success | `#82B88A` | `#2F6E43` | warm white on filled action: 5.36:1 |
| information | `#77B8C0` | `forest` when actionable | information color is never used as an unlabeled primary action |

The semantic foregrounds all exceed 7:1 on `ink` and `surface`. Each state also has an icon or text label so its meaning survives monochrome viewing and color-vision differences.

Add `scripts/build-visual-assets.sh` to validate the token schema and generate the small toolkit-specific fragments. Generated output is reproducible and must not be hand-edited. `tests/visual-static.sh` fails when a generated fragment is stale, when an unapproved literal palette color appears in owned assets, or when required foreground/background contrast falls below its gate.

Document the human-readable component rules and examples in `docs/visual-spec.md`. The specification covers button hierarchy, fields, tabs, scrollbars, menus, context menus, popovers, tooltips, notifications, progress, selections, destructive confirmation, empty/loading/offline states, window geometry, panel density, and icon placement. It also contains the approved mapping from OpenCloud grammar to Nodesktop surfaces:

| OpenCloud grammar | Nodesktop implementation |
| --- | --- |
| technical grid and generous field | wallpaper and uncluttered desktop |
| Newsreader editorial hierarchy | window titles, optional clock/date, welcome/about only |
| Inter navigation/body | GTK, menu, panel, file manager, and ordinary app UI |
| JetBrains Mono labels | telemetry, terminal, state codes, and small technical labels |
| muted teal primary action | forest primary/focus action |
| one-pixel rules and 3 px controls | panel/menu/dialog separation and compact controls |
| numbered engineering markers | workspace labels and optional welcome/help structure, never decorative clutter |

### Surface ownership matrix

The implementation begins by recording the actual toolkit/version for every shipped executable. The expected ownership is:

| Surface | Implementation owner | Required treatment |
| --- | --- | --- |
| KasmVNC browser client | Nodesktop web overlay | full branded-neutral shell, state coverage, responsive controls |
| XFCE/XFWM, Thunar, App Finder, panel plugins | Orchis patch + XFCE configuration | complete token/state mapping |
| Whisker Menu | GTK theme + explicit plugin configuration | menu mark, favorites, search, categories, keyboard states |
| GTK file chooser and common dialogs | GTK theme | places icons, controls, focus, destructive/error states |
| Papers/libadwaita applications | supported dark preference + native libadwaita styling | coherent palette and typography; do not force unsupported CSS injection |
| Firefox | system dark preference, enterprise policy, XFWM frame | coherent system integration; no brittle `userChrome.css` dependency |
| Tor Browser | vendor-native browser chrome + XFWM frame | do not modify the security profile or add fingerprinting differences |
| FileZilla/wxGTK | GTK bridge + app inspection | verify control, tree, toolbar, and dialog legibility |
| Transmission and Nicotine+ | GTK theme + supported preferences | normal, progress, paused, offline, warning, and error states |
| Geany | GTK theme + packaged editor color scheme | chrome and editor canvas both conform |
| Sublime Text | packaged `.sublime-theme` and color scheme | supported app-level configuration, including tabs and sidebar |
| XFCE Terminal and `btop` | generated palettes | ANSI/semantic colors, selections, cursor, charts, and warnings |
| Native application icons | upstream application packages | retain recognizable product identity |

An application that cannot be safely themed remains vendor-native inside a coherent XFWM frame. Such an exception must be named in the matrix with screenshots and a reason; visual inconsistency may not be silently deferred.

### KasmVNC browser-client skin

The browser-facing client is part of the product and must be redesigned before the desktop is visible.

- Copy the installed upstream web tree at build time to `/usr/local/share/nodesktop/kasmvnc-www`; never edit the package-owned tree in place.
- Add `assets/kasmvnc/nodesktop.css`, the original Nodesktop mark, favicon, and minimal HTML metadata through a version-scoped patch under `patches/kasmvnc/<version>/`.
- Change `server.http.httpd_directory` to the Nodesktop copy only after the patch verifies its expected upstream anchors. A KasmVNC update fails the build if those anchors or recorded input checksums change.
- Do not patch authentication, WebSocket, clipboard, keyboard, encoding, or session JavaScript. The overlay may change presentation and accessible labels only.
- Avoid web fonts on the pre-authentication page. Use a compact local/system fallback stack there so the sign-in view has no external fetch and remains usable before the desktop font payload is available.
- Cover sign-in, empty password, rejected password, rate-limit message, connecting, slow connection, reconnect, disconnected, session replacement, control drawer, settings, clipboard, fullscreen, and unsupported-browser messaging.
- Test at 1280 × 720 in addition to the three desktop resolutions because the browser viewport is smaller than the remote framebuffer. The control drawer must remain usable at 200% browser zoom and at a 1024 px viewport.

### XFCE shell and system states

Configure and capture all shell-owned surfaces, not only the resting desktop:

- top panel, compact launcher/telemetry panel, tasklist, workspace switcher, clock, systray, directory menu, action menu, overflow, autohide/edge behavior, and tooltip placement;
- Whisker default, search, no-results, favorites, category, keyboard focus, context menu, and recently-used states;
- desktop empty state, desktop icons, right-click menu, wallpaper across every workspace, drag selection, mount/unmount feedback, and unavailable mount state;
- XFWM active/inactive/maximized/tiled/urgent windows and move/resize overlays;
- notifications for information, success, warning, error, long text, and action buttons;
- authentication prompts plus logout, restart, shutdown, failed-launch, file-conflict, permission-denied, and destructive-confirmation dialogs.

Panel layouts must be position-independent. Replace the current absolute 1440-pixel placement with generated 100% and 125% profiles that anchor panels through XFCE positions and validated lengths.

### Scale and density profiles

Add a supported runtime setting, `NODESKTOP_UI_SCALE=100|125`, defaulting to `100`. The style migration installs the matching generated XFCE profile:

| Value | Xft DPI | UI font | Cursor | Top/bottom panel | Desktop icon |
| --- | ---: | ---: | ---: | ---: | ---: |
| `100` | 96 | 10 pt | 24 px | 32 / 40 px | 48 px |
| `125` | 120 | 10.5–11 pt | 32 px | 40 / 50 px | 56–64 px |

Do not emulate fractional GTK scaling with unsupported environment values. Use Xft DPI plus explicit XFCE panel, cursor, icon, terminal, and XFWM font values. KasmVNC browser zoom is tested separately and is not treated as the desktop scale setting. User overrides remain authoritative after the one-time migration.

### Style migration and rollback

Replace the current directory-copy migration with a key-aware, versioned migration under `scripts/migrate-style.sh`:

1. Record the previous Nodesktop default values in a versioned manifest rather than assuming every value in the user profile is Nodesktop-owned.
2. Before the first redesign migration, archive only files that will be touched to `${HOME}/.config/nodesktop/backups/<timestamp>-<from-version>/` and write a checksum manifest. Never archive documents, browser profiles, application data, or secrets.
3. For XML/INI/JSON settings, update a value only when it is absent or still equals a known prior Nodesktop default. Preserve a value that differs from the prior default as a user override.
4. Add new owned assets and keys without removing unrelated user keys, launchers, favorites, bookmarks, or panel plugins.
5. Apply `NODESKTOP_UI_SCALE` only when the user has not already changed the associated DPI/panel/cursor/icon values, unless `NODESKTOP_FORCE_STYLE=1` is deliberately set by the operator.
6. Validate the migrated files before moving the style marker. On failure, restore the scoped backup atomically and leave the previous style marker in place.
7. Provide `nodesktop-style-rollback <version>` to restore a recorded scoped backup after displaying the affected files. It must refuse to overwrite files changed since the backup without an explicit `--force`.

Tests cover clean homes, untouched 2.0.0 homes, partially customized homes, repeated/idempotent starts, interrupted migration, invalid generated configuration, scale changes, and rollback after subsequent user edits.

### Accessibility and interaction gates

- Focus uses a two-pixel sage/warm-white outline with an offset that remains visible against both `ink` and `surface`.
- Hover, focus, selected, and disabled states have non-color cues such as outline, fill, underline, icon, or label changes.
- Destructive actions retain a distinct red family; warnings retain amber; success uses a green distinguishable from the primary-action forest.
- Body copy and disabled-but-readable labels are tested independently. Placeholder text cannot be the only label.
- Keyboard-only scripts cover KasmVNC sign-in and controls, Whisker, panel traversal, window switching, common dialogs, Thunar, and terminal copy/paste.
- Test 100%, 125%, 200% browser zoom, long Spanish labels, CJK samples, and a 150% text-only font override for clipping and ellipsis.
- Animation remains optional and finite. With compositor effects disabled, no essential state may depend on transition or motion.

### Visual conformance manifest

Add `tests/visual/surfaces.tsv` with one row per required capture: identifier, image target, architecture, resolution, scale, setup fixture, expected focus/state, and masking rule for volatile data. At minimum it includes:

- KasmVNC pre-authentication and connection states;
- empty desktop and every XFCE shell/system state listed above;
- Whisker, Thunar, file chooser, terminal, `btop`, Firefox, Geany, Papers, and 7zip in `core`;
- every additional `full` application in resting, active/progress where applicable, and representative error/offline states;
- GTK2/3/4 or libadwaita component fixtures sufficient to expose controls not reached naturally by the application matrix.

`tests/visual-capture.sh` consumes the manifest through the real KasmVNC browser, stores lossless candidate captures as CI artifacts, and emits a contact sheet for each resolution/scale. `tests/visual-audit.py` performs palette, contrast, missing-icon, legacy-blue, clipping, and perceptual-diff checks. Masks may cover clocks, transfer rates, cursors, and other named volatile regions only; they cannot hide controls or application content.

Approved reference images are versioned by design revision. A perceptual change requires an updated contact sheet and explicit visual approval, not merely replacement of baseline files.

## Desktop and tool decisions

| Function | Decision | Reason |
| --- | --- | --- |
| desktop/window manager | keep XFCE/XFWM 4.20 | current stable, modular, low overhead, and already integrated with KasmVNC/X11 |
| browser desktop transport | keep KasmVNC 1.5 | modern secure web client, relative mouse, multi-monitor fixes, current upstream packages for AMD64/ARM64 |
| application menu | add Whisker Menu; keep App Finder shortcut | search/favorites improve UX for ~1 MiB installed; no resident Electron or compositor |
| panel telemetry | keep XFCE netload/systemload; add a styled `btop` launcher | the two plugins total under 1 MiB installed; Conky would add about 63 MiB of new dependencies in this image and run continuously |
| file manager | keep Thunar/Tumbler | lightweight, native, complete remote-file workflow |
| terminal | keep XFCE Terminal, change to JetBrains Mono | smaller integration cost than Kitty/Alacritty and no GPU dependency |
| text/code editing | keep Geany in core and Sublime in full | replacing either with Mousepad removes features while Mousepad would add about 8 MiB in the current dependency set |
| PDF | keep Papers initially | modern maintained viewer already present; compare complete dependency delta and launch RSS against Evince/Atril before any change |
| FTP | keep FileZilla in full | GUI functionality and saved-site workflow have no equally complete lightweight drop-in |
| BitTorrent | keep Transmission GTK in full | current, native GUI, and already from backports |
| Soulseek | keep Nicotine+ in full | unique protocol/functionality |
| cloud sync | keep rclone single binary and launcher | broad backend support for low incremental complexity |
| privacy | keep Tor Browser on AMD64 and tested Tor+Firefox fallback on ARM64 | a normal browser over Tor is not a security-equivalent replacement, so no false claim of parity |
| shell framework | replace Bash-it only if a small prompt/completion config passes parity tests | current config uses the clean theme only; expected compressed saving ~1.3 MB and faster shell startup |

LXQt, Openbox, a Wayland compositor, rofi, Conky, GNOME Shell, Plank, and Electron-based replacements are rejected for this pass. They either duplicate the current stack, add visual inconsistency/dependencies, or weaken the already-tested KasmVNC path. They can be revisited only with measured whole-image and end-to-end benefits.

## Image architecture and slimming work

### Build outputs

- `core`: XFCE, KasmVNC, Firefox, Thunar, terminal, Whisker/App Finder, Geany, Papers, 7zip, and btop.
- `full`: core plus FileZilla, Nicotine+, Transmission, Sublime, rclone, Tor CLI, and the privacy launcher.
- `full-amd64`: full plus official Tor Browser; this remains the HQ production image.
- `full-arm64`: full with the clearly labeled Firefox + Tor fallback.
- Optional future functional targets (`privacy`, `transfer`, `developer`) may be published, but they do not redefine `full`.

### No-function-loss savings to implement first

1. Replace both generated Tela trees (~6.1 MB gzip) with the compact overlay and inherited system icons.
2. Remove unused Lato (~6.1 MB gzip) after font resolution tests.
3. Replace 13 Roobert files (~1.4 MB gzip) and Inconsolata with three licensed variable families, then subset only the UI faces if fontconfig/render tests pass.
4. Replace Bash-it (~1.34 MB gzip) with a tiny prompt/completion configuration only after parity tests.
5. Make the new SVG wallpaper the default (<40 KB) while deciding whether to retain the 1 MB Turrell option.
6. Remove duplicate caches and generated artifacts only when their runtime regeneration cost and permissions are tested.
7. Reorder Dockerfile steps so fast-changing configuration layers sit above slow application layers and BuildKit cache mounts accelerate APT/download work without persisting caches into the result.
8. Keep `--no-install-recommends`, purge build-only packages in the same layer, and validate autoremove output. Do not manually copy libraries out of Debian packages to trick APT.

### Explicitly rejected “savings”

- Do not delete `/var/lib/dpkg`: it saves only ~2.43 MB compressed and breaks reliable inventory, SBOM/CVE correlation, support, and package operations.
- Do not remove WQY or fallback fonts from `full`; that would reduce document/language functionality. A separately labeled Latin-only image could be considered later.
- Do not replace Tor Browser with ordinary Firefox-over-Tor on AMD64.
- Do not minify or strip licenses, copyright notices, CA material, or desktop metadata.
- Do not use `UPX` on security-sensitive binaries or vendor browsers.

## Responsiveness work

- Capture clean baselines with five fresh containers before changing code: time to healthy, time to first rendered desktop, idle cgroup memory/CPU/PIDs, menu latency, first Thunar/terminal launch, and KasmVNC transferred bytes.
- Disable compositor effects that create encoding churn; retain window compositing only if tearing/quality testing proves it necessary.
- Prefer opaque large surfaces and static gradients. Remote codecs handle them better than blur, transparency, and animated noise.
- Keep thumbnailing on demand. Limit Tumbler plugins/timeouts for remote and huge media files without disabling ordinary thumbnails.
- Ensure Tor, rclone, btop, Transmission, Nicotine+, and browser processes start only when launched.
- Avoid session restoration of stale applications in the immutable image default.
- Use KasmVNC 1.5 codec/quality presets as an experiment matrix. HQ’s Intel Atom C3558 must be tested before enabling H.264/AV1; a newer codec is not automatically faster without working hardware acceleration.
- Measure Firefox cold-start policies and avoid preinstalled extensions. Managed bookmarks are data, not an extension.
- Cache font/icon indexes at build time and verify they remain readable under a read-only root filesystem.

## HQ-aware integration

The live HQ inventory contains user-facing services for TrueNAS, Filebrowser, Plex, Lyrion, FutPilot, AutoDJ, Radarr, Sonarr, Lidarr, Readarr, Prowlarr, Jackett, Transmission, DDNS, and DUC. It also contains internal-only infrastructure that must not be exposed or bookmarked until authoritative routes are verified.

Plan:

- Add a curated `HQ` managed-bookmark folder, not a dump of every container.
- Primary bookmarks: TrueNAS, Filebrowser, Plex, Lyrion, FutPilot, and AutoDJ.
- Secondary `Media automation` folder: Radarr, Sonarr, Lidarr, Readarr, Prowlarr, Jackett, and Transmission.
- Do not store usernames, passwords, API keys, query tokens, or cookies in bookmarks or image layers.
- Use friendly HTTPS DNS routes when available; do not cement raw ports/IPs into the public image.
- Keep HQ configuration as a read-only runtime policy mount or an HQ-specific build/config overlay. The public Docker image stays generic.
- Use Firefox `ManagedBookmarks`, `DisplayBookmarksToolbar`, and local favicon/icon files. Do not install a bookmark extension.
- Create at most four desktop shortcuts (Files, Plex, FutPilot, TrueNAS) to avoid clutter; the rest live in Firefox.
- Validate each URL from inside the container and through the visible browser before inclusion.
- Inventory the existing Traefik/Authelia routes. If they can proxy KasmVNC WebSockets safely, move external access to central TLS/SSO and stop publishing 6901 broadly. Keep KasmVNC authentication as defense in depth.
- Install an internal CA in Firefox only through the supported certificate policy and only after its provenance, rotation, and hostname coverage are verified.

## Update, supply-chain, and security plan

- Pin Debian base images by version and digest. Rebuild on every stable point release and security update rather than mutating running containers.
- Add a machine-readable dependency manifest containing version, upstream URL, architecture, checksum, license, and update source for every non-APT asset.
- Add scheduled update detection (Dependabot for actions/base references plus a checksum-aware script or Renovate-compatible custom rules for Dockerfile arguments).
- CI must verify upstream checksums before proposing version changes; never fetch `latest` during a release build.
- Generate SPDX SBOM and `provenance=mode=max` attestations with BuildKit for every pushed architecture.
- Scan the final images, not only the source tree. Keep the dpkg database so Debian advisory matching remains accurate, and complement it with file/binary scanning for Firefox, Tor Browser, btop, and rclone.
- Scan source/config for secrets and licenses. Fail on a committed VNC secret, private key, or unapproved commercial font.
- Add OCI revision, created time, version, source, license, and base-digest labels.
- Sign release indexes with Cosign/keyless signing if the Docker Hub workflow and HQ verifier can support it; document verification before enforcement.
- Deploy HQ by digest with a recorded prior digest and an automatic rollback command.
- Continue non-root runtime, secret files, health checks, restart policy, minimal mounts, and no privileged mode.
- Add resource ceilings appropriate for HQ after observing real use: memory high/limit and CPU shares, with no limit low enough to kill Firefox during legitimate work.
- Replace the self-signed direct endpoint with centrally managed TLS/SSO when the existing HQ proxy topology is confirmed.

## Test strategy

### Static and build tests

- `bash -n`, ShellCheck, and formatting checks for every shell script.
- `xmllint --noout` for XFCE/Thunar XML, `jq` for JSON, `desktop-file-validate` for launchers, and XML/SVG validation for icons/wallpaper.
- Font metadata/license/glyph checks with fonttools; render an English, Spanish, symbol, and CJK specimen.
- Validate `assets/design/tokens.json`, regenerate all owned theme fragments in a clean directory, and fail if the checked-in or image-installed output differs.
- Verify the KasmVNC patch against the pinned upstream tree and fail if an expected anchor, input checksum, local asset, accessible label, title, or favicon is absent.
- Generate the application/toolkit ownership inventory and fail when an installed GUI executable or `.desktop` launcher has no recorded visual owner.
- `docker build --check .` with zero actionable warnings.
- Build `core` and `full` on ARM64 locally, then build Linux AMD64 and ARM64 through Buildx.
- Record compressed size per manifest and per layer; compare against the saved baseline and gates.
- Verify SBOM coverage includes Debian and non-Debian applications; run vulnerability and secret/license scans.

### Automated runtime tests

- Start with a password secret file, non-root user, read-only root, capability drop, `no-new-privileges`, tmpfs runtime directories, and loopback-only local publish.
- Confirm health, TLS/authentication, rejected wrong password, WebSocket connection, display geometry, and clean signal shutdown.
- Validate theme/font/icon settings and resolve/render all application launchers.
- Assert both `NODESKTOP_UI_SCALE` profiles install the intended DPI, cursor, panel, desktop-icon, XFWM, and terminal values without changing the framebuffer geometry.
- Validate style migration on a clean home, a 2.0.0 home, and a user-modified home without deleting unrelated settings.
- Test every architecture-specific launcher and fail if an unavailable tool is shown as installed.

### End-to-end visible tool matrix

Use the real browser-controlled KasmVNC session, not only process checks:

- Whisker Menu and App Finder: search, favorites, keyboard navigation, and menu mark.
- Thunar: open each mounted HQ dataset; create/rename/copy/delete a temporary fixture; verify green folders everywhere.
- XFCE Terminal: shell startup, completion, copy/paste, Unicode, and `btop` rendering.
- Firefox: first-launch legal prompt handed to the user, navigation, download/upload fixture, managed bookmarks, PDF handling, and no certificate bypass baked into the image.
- Geany and Sublime: create, edit, save, reopen, and compare a fixture.
- Papers: open, search, zoom, and print-preview a fixture PDF.
- 7zip: archive, list, test, and extract a fixture.
- FileZilla: connect to a disposable local test server, transfer both directions, and verify the files.
- Transmission: open the UI and validate configuration against an isolated legal/local fixture; do not rely on public copyrighted torrents.
- Nicotine+: launch, settings persistence, and offline/error behavior; a live Soulseek transfer requires a separately authorized test account.
- rclone: local-to-local copy, checksum, move, and delete fixture.
- Tor: bootstrap, verify a request through the SOCKS listener, and shut down cleanly.
- Tor Browser on AMD64: launch the official browser and verify Tor status without changing its security profile. On ARM64, verify the clearly labeled fallback.

### Visual and performance tests

- Execute every row in `tests/visual/surfaces.tsv` at 1440 × 900, 1680 × 1050, and 1920 × 1080 for both UI scales; include the 1280 × 720 and 1024 px-wide KasmVNC web-client cases.
- Produce separate approval contact sheets for the KasmVNC entry/connection shell, XFCE shell/system states, `core` applications, `full` applications, accessibility/scale cases, and error/offline states.
- Automated pixel/color audit rejects legacy blue folder colors and checks palette bounds. Perceptual screenshots flag unintended regressions but do not replace human review.
- Fail on clipped primary controls, invisible focus, unnamed visual exceptions, unmasked volatile diffs, or an application missing from the ownership/capture matrices.
- Five cold starts and five warm starts for `core` and `full`; record p50/p95 desktop-ready time.
- Record cgroup CPU/RAM/PIDs after two idle minutes and after opening each heavy application.
- Measure menu open/search latency, Thunar first open, terminal first open, and KasmVNC transferred bytes during a standard 60-second interaction script.
- Test HQ’s Intel AMD64 host explicitly; a successful ARM64 laptop test is not a substitute.

### Release and HQ gates

1. All local static, multi-architecture, security, functional, visual, and performance gates pass.
2. Publish a versioned candidate and immutable digest; never deploy `latest`.
3. Deploy to an HQ staging instance/port with the same mounts and security context.
4. Run the complete browser E2E matrix against HQ, including every tool and bookmark reachable without third-party credentials.
5. Observe health, logs, memory, CPU, and reconnect behavior for at least ten minutes.
6. Promote the exact tested digest to the production app and retain the 2.0.0 digest as rollback.
7. Re-run critical smoke/browser tests against production, then send the readiness email with URL, username, digest, test summary, known legal prompts, and no password.

## Implementation sequence

### Phase A — Baselines, inventory, and guards

- Add dependency manifest, license inventory, SBOM/provenance build settings, CVE/secret scans, size report, and clean-start benchmarks.
- Inventory every GUI executable, `.desktop` launcher, toolkit/version, theme mechanism, and architecture-specific exception into the visual ownership matrix.
- Add tests for XML/JSON/desktop/SVG/font correctness and existing tool launches.
- Save 2.0.0 reference screenshots, including stock KasmVNC pre-authentication/connection states, and performance results.

Exit gate: every shipped visual surface has an owner and a baseline capture; no implementation begins while an application is missing from the inventory.

### Phase B — Design contract and core assets

- Add `assets/design/tokens.json`, `docs/visual-spec.md`, the generator, and static token/contrast checks.
- Add licensed Inter/Newsreader/JetBrains Mono assets and notices.
- Build the original wallpaper, Nodesktop mark, favicon, and compact overlay icon theme with green places and Lucide-derived actions.
- Generate the Orchis palette/state patch, terminal palette, `btop` theme, web CSS variables, and 100%/125% XFCE profiles.

Approval checkpoint 1: tokens, typography, spacing/density, semantic states, wallpaper, icon family, and OpenCloud-to-Nodesktop translation.

### Phase C — KasmVNC product shell

- Create the version-checked web-tree copy and presentation-only patch.
- Implement sign-in, connection, reconnect, disconnected, session, drawer, settings, clipboard, fullscreen, zoom, and narrow-viewport treatments.
- Verify that no authentication, transport, encoding, clipboard, keyboard, or session behavior changed.

Approval checkpoint 2: KasmVNC contact sheet at default, narrow, zoomed, success, and failure states plus keyboard traversal.

### Phase D — XFCE shell and common components

- Patch Orchis tokens and complete GTK/XFWM state coverage.
- Configure Whisker Menu, favorites, shortcuts, panel layout, workspace labels, tasklist, systray, clock, notifications, action menu, terminal palette, and `btop` theme.
- Remove absolute panel placement and install generated 100%/125% profiles.
- Implement the versioned style migration with user-override detection and a recorded rollback copy of replaced Nodesktop-owned settings.

Approval checkpoint 3: desktop, panels, menu, common controls, file chooser, notifications, system/action dialogs, window states, scaling, and focus behavior.

### Phase E — Application adapters

- Apply the GTK integration and supported application-level themes/preferences described by the ownership matrix.
- Add Geany editor, Sublime Text, terminal, and `btop` schemes; configure system dark preference for compatible applications.
- Add generic Firefox policy improvements without `userChrome.css` and without auto-accepting legal terms.
- Preserve Tor Browser’s vendor chrome/security profile and document the deliberate exception.
- Capture every `core` and `full` application in resting, working/progress where applicable, and representative error/offline states.

Approval checkpoint 4: complete application contact sheets with every exception explicitly accepted.

### Phase F — Visual automation and accessibility

- Add `tests/visual/surfaces.tsv`, deterministic fixtures, capture runner, audit tool, masks, and contact-sheet generation.
- Execute the full resolution/scale/language/zoom matrix and keyboard-only paths.
- Fix clipping, missing icons, legacy blue, invisible focus, semantic ambiguity, and unintended toolkit fallbacks before approving new baselines.

Exit gate: every manifest row passes automated checks and all five contact-sheet groups have explicit human approval.

### Phase G — Slimming and responsiveness

- Remove unused Tela, Lato, Roobert, and Inconsolata payloads after fallback tests.
- Replace Bash-it only after prompt/completion parity.
- Tune thumbnails, session restoration, KasmVNC settings, and Docker layer order.
- Repeat size/CPU/RAM/start/interaction measurements after each change; revert changes with no measured benefit.

### Phase H — HQ overlay

- Verify public routes and proxy/SSO topology.
- Add runtime-mounted HQ Firefox policy/bookmarks and the limited desktop shortcuts.
- Validate every link from inside the visible HQ browser; do not publish internal-only endpoints.
- Capture the HQ overlay at both scale profiles without placing private URLs or user data in public reference artifacts.

### Phase I — Candidate, E2E, and production

- Build and test ARM64 and AMD64 candidates locally.
- Publish SBOM/provenance-attested multi-arch candidate.
- Stage on HQ, exercise every tool and visual-manifest state in the browser, measure, promote by digest, re-test, and email readiness.

## Definition of done

The branch is complete only when the KasmVNC product shell, XFCE shell/system states, common component states, and every `core`/`full` application have an owner and approved contact sheet; every visual-manifest row passes at both UI scales; all documented accessibility gates pass; every deliberate vendor-native exception is approved; every `full` function passes the tool matrix; size and responsiveness meet the hard gates; no blue folder glyph remains; font and asset licenses are present; both architectures build; the published index has SBOM/provenance; the exact AMD64 digest passes the full HQ browser test; production is healthy; rollback is recorded; and the readiness email has been sent.

## Primary research sources

- [OpenCloud visual reference](https://opencloud.org/) and [OpenCloud terms](https://opencloud.org/terms)
- [Debian current releases](https://www.debian.org/releases/)
- [XFCE current stable release](https://xfce.org/download) and [XFCE 4.20 changes](https://xfce.org/download/changelogs/4.20)
- [KasmVNC releases](https://github.com/kasmtech/KasmVNC/releases)
- [Whisker Menu](https://github.com/xfce-mirror/xfce4-whiskermenu-plugin)
- [Inter](https://github.com/rsms/inter), [Newsreader](https://github.com/productiontype/Newsreader), and [JetBrains Mono](https://www.jetbrains.com/lp/mono/)
- [Lucide license](https://github.com/lucide-icons/lucide/blob/main/LICENSE)
- [Orchis](https://github.com/vinceliuice/Orchis-theme) and [Tela Circle](https://github.com/vinceliuice/Tela-circle-icon-theme)
- [Firefox enterprise policy reference](https://mozilla.github.io/enterprise-admin-reference/reference/policies/)
- [rclone changelog](https://rclone.org/changelog/) and [Go vulnerability database](https://pkg.go.dev/vuln/)
- [Docker SBOM attestations](https://docs.docker.com/build/metadata/attestations/sbom/) and [build provenance](https://docs.docker.com/build/metadata/attestations/)
- [Trivy image scanning behavior](https://github.com/aquasecurity/trivy/blob/main/docs/guide/target/container_image.md)
