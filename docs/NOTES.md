# TTNS Roku — notes

Working notes for the `v0.1.0-alpha` sideload. This is the living-room dogfood build, not a store release.

## Product intent

A public TV companion to ttns.fm:

- Listen to the live stream without a phone.
- Browse gig posters and the community board on the sofa.
- Never take money, never take a login, never open a webview.

Anything that needs a form (tickets, replies, artist sign-up, promote) shows a website address and stops there.

## Public endpoints

No secrets. The channel polls:

| Feed | URL |
|---|---|
| Now playing | `https://nowplaying.ttns.uk/trackinfo/current` |
| Live canvas / ident | `https://canvas.ttns.uk/api/state.php` (`state.canvas.url`) |
| Chat | `https://chatbot.ttns.uk/api/messages.php?limit=25` |
| Custom emoji list | `https://chatbot.ttns.uk/api/emojis.php` |
| Gigs | `{city}/api/schedule?date=YYYY-MM-DD&public=true` (one day at a time, 14 days) |
| Community listings | `{city}/api/community/listings` |
| Community acts | `{city}/api/community/acts` |
| Promote / prices | `{city}/plans` (scraped to public plan cards) |

Roku cannot iframe those sites. Listen Live is native posters + labels over the public JSON.

## Why gigs are slow

The bulk schedule payload (`/api/schedule/bulk?public=true`, ~14 days) is huge (around 2 MB) and hung the box. `ScheduleTask` therefore walks **one public day at a time**, merges events, and caps the grid at 80. That is why Gigs (and to a lesser extent Community) show a centered spinner until the task finishes.

Do not switch back to the bulk endpoint without a slimmer payload.

## Listen Live

- Placeholder artwork is the transparent circular logo. The green live frame only appears after a real canvas URL has loaded.
- **ON AIR** colour-pulses between green and orange while playing; grey when paused.
- Chat is a `MarkupList` of `ChatRow` items. Down from the player enters chat; Up / Back returns to the player.
- Image URLs are stripped from chat text. Attachments and embed thumbnails show as large `scaleToFit` photos, never as raw `https://…` strings.
- Custom Discord emojis (`<:name:id>`) render as Discord CDN posters. A small set of common unicode emoji from `emojis.php` maps to Twemoji PNGs. Roku labels **cannot** draw emoji glyphs.
- If you scroll up through chat, a 10 second timer jumps back to the newest message so the list can follow again.
- Left / Right change station only while focus is on the player, not while you are in chat.
- Audio lives on `MainScene` so it keeps playing when you leave Listen for gigs / community.

## Branding

- Source mark: `images/ttns-logo-source.jpg` (red circle; JPEG has no alpha).
- `scripts/make_images.py` punches the black to transparency, writes a square `images/ttns-logo.png`, and rebuilds splash / channel posters / spinner.
- Channel posters are the required Roku rectangles (540×405, 336×210, 246×140) with the **round** logo centred on `#0a0a0a`. No green stripe. Roku will stretch a wrong-aspect poster and squash the circle — keep those sizes exact and never scale the mark itself.

## BrightScript / SceneGraph (OS 15)

Hard rules learned the painful way. Breaking these crashes the channel or silently eats keys.

1. Component scripts do **not** see `source/` unless each XML includes the `.brs` files it needs.
2. No method chaining: not `foo().Bar()`, not `ToInt().ToStr()`, not `CityForListings(...).siteUrl`.
3. Do not pass `m.index = 0` as a function argument.
4. Avoid unicode literals in `.brs` files (use `GBP`, not `£`). Runtime strings from JSON are fine.
5. `focusable="true"` on `<component>` is invalid. Set `m.top.focusable = true` in `init()`.
6. ContentNode fields that exist: `title`, `description`, `HDPosterUrl`, `ShortDescriptionLine1`. **`HDDescription` does not exist.**
7. `step` is a reserved word. Do not use it as a parameter name.
8. Do not mix a single-line `if … then` with `else if`.
9. `roFontRegistry` cannot be created on the render thread. Marquee width is estimated with `Len(text) * fontSize * factor`.
10. Do not set Task `events = []` / `ready = false` at the start of a run (observers fire early). Observe `ready`.
11. MarkupGrid does **not** have `wrap`. It eats Up / OK. First-row Up is stolen in `PosterCard` via `m.global.listFilterTick`.
12. MarkupGrid `itemSelected` often does **not** fire for index 0 when it is already 0.
13. Rectangle / MarkupGrid on this firmware do **not** have `nextFocusDown` / `nextFocusUp`. Move focus in `onKeyEvent`.

## Alpha known limits

- Not in the Channel Store. Sideload only.
- Bristol is `comingSoon` and is skipped by Left / Right on Listen.
- Native emoji in chat text still missing (posters only).
- Chat is read-only. No posting from the TV.
- Gig / community load time is bound to sequential HTTP. Spinner is the honest UX.
- First-row MarkupGrid OK can be flaky; poster cards and plan lists work around it.
- Channel home-row icon is a landscape tile. The logo inside is circular; the tile itself cannot be.

## Living-room test box

Development has been sideloaded to a 65" TCL on Roku OS 15.3.x. After `make sideload`, BrightScript console is `telnet <roku-ip> 8085`.
