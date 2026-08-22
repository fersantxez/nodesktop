# Nodesktop visual specification

`assets/design/tokens.json` is the canonical machine-readable contract. Generated files under `config/generated/` are never hand-edited.

## Hierarchy and density

The shell uses carbon and ink as structural surfaces, forest for primary selection, olive and sage for secondary emphasis, warm white for headings, and body/muted neutrals for text. Gold is limited to small status and telemetry accents. Controls use 3 px radii, dialogs and menus 5 px, one-pixel structural rules, and a two-pixel visible focus outline.

Inter is the interface face, Newsreader is reserved for window-title and editorial moments, and JetBrains Mono owns terminal and telemetry. Dense controls remain compact, but primary remote-desktop targets are at least 32 px.

## Component states

- Primary buttons use forest fill and warm-white text; hover adds a sage edge and pressed state visibly darkens.
- Secondary buttons use surface fill and a one-pixel rule; focus always adds a two-pixel outline.
- Disabled controls reduce contrast but retain readable labels and shape.
- Danger remains red, warning amber, success green, and information cyan. Every semantic state also carries text or an icon.
- Fields retain persistent labels, a visible insertion point, error text, and non-color focus/error cues.
- Tabs and menu selections combine fill with an underline or outline. Tooltips use carbon, warm white, and a structural border.
- Progress, loading, empty, offline, and reconnect states use explicit labels and finite motion only.
- Destructive confirmations name the affected object and keep Cancel visually available.

## Surface mapping

| Surface | Owner | Treatment |
| --- | --- | --- |
| KasmVNC web client | Nodesktop presentation overlay | local CSS/mark/favicon; behavior untouched |
| XFCE, XFWM, Thunar, panels, file chooser | Orchis + generated XFCE configuration | full token and focus mapping |
| Whisker Menu | GTK theme + explicit configuration | original menu mark, search, categories, favorites |
| Papers/libadwaita | supported dark preference | native libadwaita behavior retained |
| Firefox | enterprise policy + system dark preference | no `userChrome.css` |
| Tor Browser | vendor-native | security profile and browser chrome untouched |
| FileZilla | wxGTK bridge | legibility and state captures required |
| Transmission and Nicotine+ | GTK + supported preferences | progress/offline/error captures required |
| Geany | GTK + Nodesktop editor scheme | chrome and editor canvas owned |
| Sublime Text | supported theme/color scheme | tabs/sidebar/editor owned |
| Terminal and btop | generated palettes | ANSI, selection, cursor, warnings, charts |
| Native application icons | upstream packages | recognizable product identity retained |

## OpenCloud grammar translation

The design borrows restraint, technical rhythm, one-pixel rules, and editorial hierarchy—not branding or proprietary assets. The technical grid becomes the static wallpaper; forest replaces teal; Inter, Newsreader, and JetBrains Mono map to interface, editorial, and technical roles; small engineering marks are functional rather than decorative.

## Accessibility and responsive rules

Normal text must reach 4.5:1 contrast and large/non-text controls 3:1. Keyboard focus is never color-only. Tests cover 100% and 125% desktop profiles, 200% browser zoom, 1024 px KasmVNC width, English, Spanish, accented Latin, symbols, and CJK fallback. Large opaque surfaces are preferred over blur and transparency to preserve remote-encoding quality.
