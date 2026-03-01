# Homarr Plex Theme Pack

This folder now contains a full Plex-style theme pack tailored for current Homarr builds.

## Files

- `plex-mobile.css`
  - Core Plex visual system
  - Mobile-first overrides
  - Works on its own

- `plex-desktop.css`
  - Desktop-only refinements (`min-width: 769px`)
  - Intended to layer on top of `plex-mobile.css`

- `plex-complete.css`
  - Entry file that imports both `plex-mobile.css` and `plex-desktop.css`

## Recommended usage

Use one of these approaches:

1. **Single file:** Load `plex-mobile.css` only.
2. **Best parity:** Load `plex-complete.css` (or load `plex-mobile.css` then `plex-desktop.css`).

## Important Homarr note

Current Homarr stores board custom CSS in the database (`board.custom_css`).
If you apply CSS through the board settings editor, paste the CSS content directly.
If you apply CSS via your own mount/reverse-proxy/static injection path, use these files directly.

## Tuning tips

- Accent color is controlled by `--plex-accent` in `plex-mobile.css`.
- Surface/background tones are controlled by the `--plex-*` variables near the top of `plex-mobile.css`.
- If a widget needs special styling, add a custom CSS class in widget advanced options and target it from these files.
