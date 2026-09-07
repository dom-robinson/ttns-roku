# TTNS FM for Roku

Sideloadable [Roku](https://www.roku.com) channel for the public parts of [ttns.fm](https://www.ttns.fm): **live radio**, **gig listings**, and the **community board**.

Tickets, replies, posting, and plan sign-up stay on the websites. The TV app tells people to open `www.ttns.fm`, `brighton.ttns.fm`, or `bristol.ttns.fm` on a phone or laptop.

This channel does **not** need API keys, Discord tokens, or Channel Store secrets in the repo. Everything it reads is already public.

**Status:** `v0.1.0-alpha` — living-room dogfood on Roku OS 15, not a Channel Store release.

## What it does

| Screen | Source | TV behaviour |
|---|---|---|
| Listen live | Brighton SharpStream + national Icecast MP3 | Play / pause, station switch, live canvas ident, now playing, scrollable read-only chat |
| Gigs | `{city}/api/schedule?date=&public=true` (14 days, sequential) | Poster grid with When / Venue filters. Booking → website hint |
| Community | `{city}/api/community/listings` and `/acts` | Poster grid with category filter. Reply / post / sign-up → website hint |
| Promote | Public prices from the city `/plans` page | Read-only costs; sign-up stays on the website |
| On the web | — | Shows `www.ttns.fm` and the city hosts |

Station choice is remembered on the device. Default is **Brighton** (live DAB + listings). Bristol is listed and marked as still launching. National is The Thursday Night Show stream; its gigs/community views fall back to Brighton.

Emails and ticket checkout URLs from the APIs are **not** shown on screen.

## Sideload onto a Roku

1. On the Roku: **Settings → System → Developer** and enable installer. Note the device IP and the developer password you set there.
2. Copy `.env.example` to `.env` and fill in `ROKU_DEV_TARGET` and `ROKU_DEV_PASSWORD`.
3. From this folder:

```bash
python3 -m pip install pillow   # first time only, for splash / poster / logo images
set -a && source .env && set +a
make sideload
```

`make sideload` rebuilds generated images, zips `manifest`, `source`, `components`, and `images`, then posts the zip to `http://<roku-ip>/plugin_install`.

`make smoke` checks the public APIs are reachable from this machine.

## Channel Store packaging

You do **not** need TTNS backend credentials. You need a **Roku developer account** and the **packaging password** from that account.

1. Sideload the channel once so the box has a current build.
2. Set `ROKU_SIGN_PASSWORD` in `.env` to your Roku packaging password.
3. `make package` — this asks the developer device to sign a `.pkg`.
4. In the [Roku developer dashboard](https://developer.roku.com), create or reopen the channel, upload the signed package, and attach store screenshots / description.

Store assets this repo already generates:

- Channel posters: `images/channel-poster_*.png`
- Splash: `images/splash-screen_*.jpg`

You will still need Channel Store screenshots from a real Roku (home, player, gigs, community).

## Project layout

```
manifest
source/           BrightScript helpers (stations, registry, dates, chat text)
components/       SceneGraph screens + HTTP / schedule / community tasks
images/           splash, posters, transparent logo, spinner
scripts/          image render + API smoke check
docs/             notes, BrightScript gotchas, alpha caveats
```

Add a new city in `source/stations.brs` (`id`, stream URL, `https://<city>.ttns.fm`). The schedule and community tasks already use the station’s `apiBaseUrl`.

## Privacy / TV-safe rules

- No login, no forms, no payments on the TV.
- Community payloads can include emails; the channel drops those fields and only shows title, category, city, asking price, and description.
- Gig details point at the city site, not the raw ticket vendor URL.

## Docs

- [Alpha notes and known limits](docs/NOTES.md)
- [Changelog](CHANGELOG.md)

## License

Private / unpublished alpha for TTNS. Do not treat this as a public Channel Store product yet.
