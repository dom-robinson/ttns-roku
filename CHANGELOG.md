# Changelog

## v0.1.0-alpha — 2026-09-07

First dogfood cut of the public TTNS FM Roku channel. Sideload only.

### Listen live

- Brighton SharpStream and national Icecast play / pause from a persistent `<Audio>` on the scene.
- Live canvas ident from `canvas.ttns.uk`, now playing from `nowplaying.ttns.uk`.
- Transparent circular TTNS mark as the placeholder. No extra green frame until canvas actually loads.
- ON AIR colour-fades between green and orange.
- Scrollable chat: photos at a usable size, URLs stripped, custom Discord emojis as posters, 10s resume-to-newest after you scroll up.

### Gigs and community

- Poster grids with When / Venue (gigs) and Category (community) filters.
- Default load is **all upcoming** / **all listings**, then focus the posters.
- Up / Down moves between filter chips and the grid.
- Centered spinner + loading copy while the sequential 14-day schedule (or community board) fetches.
- Promote / prices is a LabelList of public plan cards, not a wall of text.

### Branding and packaging

- Official embossed circular logo, punched to a transparent PNG.
- Channel posters are the required Roku sizes with the round mark centred and no green stripe.
- Makefile sideload / package / smoke. No API keys in the repo.

### Not in this alpha

- Channel Store listing.
- Bristol as a live selectable stream (marked coming soon).
- Native emoji glyphs in labels.
- Chat posting, tickets, or sign-up on the TV.
