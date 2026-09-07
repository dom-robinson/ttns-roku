# Changelog

## v0.2.2-beta — 2026-09-07

Package submitted for a public Streaming Store listing (Roku review pending). Minimum firmware **15.1**.

- `rsg_version=1.3`. Dashboard **Minimum firmware must be 15.1** (not 9.2).
- Dropped deprecated manifest `subtitle`.
- SD channel poster is 246×140 again, which is what the analyser checks.
- `roAppMemoryMonitor` plus the legacy `EnableLowGeneralMemoryEvent` fallback. Roku turns those memory warnings into errors on 1 October 2026.

## v0.2.1-beta — 2026-09-07

Store-readiness on top of the living-room beta.

- `AppLaunchComplete` fires once when Home is usable, or when a playable deep link is buffering/playing (12s watchdog). Runtime deep links do not fire it again.
- Deep links: cold launch args plus `roInput` while running. `brighton` / `national` / `listen` play live; `gigs`, `community`, and `promote` open those screens; anything else lands on Home.
- `make screenshots` captures the six 1920×1080 Channel Store frames from the sideloaded box. `make deeplink` launches Brighton live over ECP.

## v0.2.0-beta — 2026-09-07

Living-room beta. Sideload, or share through a Roku Dashboard beta. Still not a public Streaming Store listing.

### Listen live

- Player owns every key. Chat is a custom clipped list, not a MarkupGrid, so rows can grow with wrapped text.
- Manual wrap (`WrapTextToWidth`) so chat no longer ellipsizes mid-sentence.
- Avatars stay 144×144 and do not stretch on tall rows. Up to six emoji posters per message.
- Chat highlight is a thin orange ring (`0xFF8800FF`), same idea as Promote. Do not use MarkupList `focusPercent` for this — it paints a false green on the top visible row.
- Right or Down enters chat. Left / Back leaves. OK opens a photo. Rewind / FF change station only from the player.
- Removed the “CHAT - chatbot.ttns.uk” label. The right-justified hint shows “Newest in view” or the 10s resume warning.
- Track title is red; stream line is light red. NOW PLAYING / ON AIR stay green.

### Gigs and community

- ListScreen owns every key. The poster MarkupGrid is never focused, so Rewind / FF no longer page the grid.
- Rewind / FF from posters jump to the filter chips (When / Venue / Promote, or Category / Promote). Same keys walk the chips.
- Grey status line: `{n} upcoming  -  Rewind / FF filters  -  OK for details`.
- Applying a filter stays on the filtered poster grid. The next OK opens that gig or listing.
- Removed the bottom help label that sat on top of posters.

### Promote

- Replaced the green-on-white LabelList with `PlanListRow`: dark fill, light text, thin orange border on the selected product.

### Branding

- Home-row posters are the sizes Roku actually uses: 540×405, **290×218**, **214×144**. The older 336×210 / 246×140 tiles stretched the circle into an oval.

### Repo

- Dropped unused `PlanCard` and `CardRow` leftovers.
- Channel Store packaging and certification notes live in `docs/STORE.md`.

### Still not in this beta

- Public Streaming Store listing (needs a signed `.pkg`, Dashboard listing, and certification).
- Bristol as a live selectable stream (still marked coming soon).
- Native emoji glyphs in labels.
- Chat posting, tickets, or sign-up on the TV.
- Deep-link / `AppLaunchComplete` work that a public store submission will likely need.

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
