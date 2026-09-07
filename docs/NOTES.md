# TTNS Roku — notes

Working notes for the `v0.2.0-beta` sideload. Living-room dogfood on Roku OS 15. Not a public Streaming Store listing — see [STORE.md](STORE.md) for that path.

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
- Track title is `0xFF3B3BFF`. Stream line is `0xFF9A9AFF`.
- Chat is a custom clipped `Group` list (`ChatRow`), not a MarkupGrid. PlayerScreen owns Up / Down / OK so rows can grow with wrapped text.
- Body wrap is manual (`WrapTextToWidth` in `source/utils.brs`). Roku `wrap="true"` was ellipsizing mid-sentence. Cap 10 lines, line height 40.
- Image URLs are stripped from chat text. Attachments and embed thumbnails show as `scaleToFit` photos. OK on a row with a photo opens a full-screen modal; Back closes it.
- Custom Discord emojis (`<:name:id>`) render as Discord CDN posters. A small set of common unicode emoji from `emojis.php` maps to Twemoji PNGs. Hearts need `2764.png`, not `2764-fe0f`. Roku labels **cannot** draw emoji glyphs.
- `UsableDiscordEmojiId` ignores JSON `null` ids so unicode reactions are not collapsed onto one broken Discord URL.
- Avatars: `author.avatar` or a Discord default embed. Avatar is 144×144, top-left, and does not stretch on tall rows.
- Chat highlight is orange (`0xFF8800FF`) via `m.global.chatFocusIndex`. Do **not** use MarkupList `focusPercent` — it paints a false green on the top visible row.
- If you scroll up through chat, a 10 second timer jumps back to the newest message so the list can follow again.
- Rewind / FF change station only while you are on the player, not while you are in chat.
- Audio lives on `MainScene` so it keeps playing when you leave Listen for gigs / community.

## Gigs and community

Same focus model as chat: **ListScreen owns all keys**. `m.grid.focusable = false`. Do not `setFocus` on the MarkupGrid — it pages on Rewind / FF and eats filter access.

- Highlight posters with `m.global.listFocusIndex` in `PosterCard.paintFocus`.
- Rewind / FF from the grid jump to the filter chips. Same keys walk When / Venue / Promote (gigs) or Category / Promote (community). Left / Right / Down still work on chips.
- The picker is also owned (`pickerList.focusable = false`). Up / Down `movePicker`, OK applies the choice and returns to the **filtered poster grid**. Do not observe `itemSelected` on picker or grid.
- After a filter, stay on the grid. The next OK opens the focused item via `m.top.selectedIndex = m.gridIndex`.
- Do not add a `skipOpen` lock after applying a filter. A previous version of that lock ate every later OK.

## Promote

- `MarkupList` of `PlanListRow` items, 720×68, 3px orange border when selected, dark fill, light text.
- `drawFocusFeedback="false"`. Selection is `m.global.planFocusIndex`.
- Right-hand card is the full product. Sign-up URL is the city site + `/plans`.

## Branding

- Source mark: `images/ttns-logo-source.jpg` (red circle; JPEG has no alpha).
- `scripts/make_images.py` punches the black to transparency, writes a square `images/ttns-logo.png`, and rebuilds splash / channel posters / spinner.
- Channel posters must be **540×405, 290×218, 214×144**. The older 336×210 / 246×140 docs squash a circle into an oval on the home row.
- Inscribe the circle in the short side on `#0a0a0a`. Letterboxing is required so the ring stays round. Never scale the mark itself to fill a wide tile.

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
11. MarkupGrid has **no** `wrap`. It eats Up / OK / Rewind / FF. Own those keys on the parent screen and keep the grid `focusable = false`.
12. MarkupGrid `itemSelected` often does **not** fire for index 0 when it is already 0. Drive open from `onKeyEvent`.
13. Rectangle / MarkupGrid on this firmware do **not** have `nextFocusDown` / `nextFocusUp`. Move focus in `onKeyEvent`.
14. BrightScript `Instr` returns **0** when not found. Use `Instr(...) > 0`.
15. Do not set `m.top.focusable` via XML on the component root.

## Beta known limits

- Not in the public Streaming Store. Sideload, or a 20-user Dashboard beta.
- Bristol is `comingSoon` and is skipped by Rewind / FF on Listen.
- Native emoji in chat text still missing (posters only).
- Chat is read-only. No posting from the TV.
- Gig / community load time is bound to sequential HTTP. Spinner is the honest UX.
- Channel home-row icon is a landscape tile. The logo inside is circular; the tile itself cannot be.
- Public store certification will want deep-link handling and an `AppLaunchComplete` beacon. Neither is finished. See [STORE.md](STORE.md).

## Living-room test box

Development has been sideloaded to a 65" TCL on Roku OS 15.3.x. After `make sideload`, BrightScript console is `telnet <roku-ip> 8085`.
