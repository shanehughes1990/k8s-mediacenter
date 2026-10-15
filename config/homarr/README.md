# 🎨 Homarr Plex theme pack

Oh, this folder is fun. It is a full Plex-style theme pack made for current Homarr builds: the same warm dark surfaces, the same accent glow, and a layout that feels right on a phone and on a big screen.

## The files

* `plex-mobile.css` is the heart of the look. It holds the Plex visual system and the mobile-first overrides, and it is perfectly happy on its own.
* `plex-desktop.css` adds desktop-only refinements at `min-width: 769px`. It loves sitting on top of `plex-mobile.css`.
* `plex-complete.css` is the welcome mat. It imports `plex-mobile.css` and then `plex-desktop.css`.

## How to wear it

Pick the outfit that fits the day:

1. **Just the core look.** Load `plex-mobile.css` on its own.
2. **The full outfit.** Load `plex-complete.css`, or load `plex-mobile.css` and then `plex-desktop.css`.

## A note Homarr will thank you for

Current Homarr keeps board custom CSS in the database, in `board.custom_css`.

Paste the CSS straight into the board settings editor when that is how you apply it. When you inject CSS through your own mount, reverse proxy, or static path, point that path at these files and let them shine.

## Little dials you can turn

* `--plex-accent` in `plex-mobile.css` is the accent color. Give it a new value and the whole theme follows.
* The `--plex-*` variables near the top of `plex-mobile.css` set the surfaces and backgrounds.
* A widget that wants its own flair can take a custom CSS class in its advanced options. Target that class from these files.
