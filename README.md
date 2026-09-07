# TTNS FM for Roku

Sideloadable [Roku](https://www.roku.com) channel for the public parts of [ttns.fm](https://www.ttns.fm): **live radio**, **gig listings**, and the **community board**.

Tickets, replies, posting, and plan sign-up stay on the websites. The TV app tells people to open `www.ttns.fm`, `brighton.ttns.fm`, or `bristol.ttns.fm` on a phone or laptop.

This channel does **not** need API keys, Discord tokens, or Channel Store secrets in the repo. Everything it reads is already public.

**Status:** `v0.2.2-beta` — the package submitted to the Roku Streaming Store (minimum firmware 15.1). Sideload and the Dashboard beta still work while Roku reviews the public listing.

## What it does

| Screen | Source | TV behaviour |
|---|---|---|
| Listen live | Brighton SharpStream + national Icecast MP3 | Play / pause, Rewind / FF station, live canvas ident, now playing, custom chat list |
| Gigs | `{city}/api/schedule?date=&public=true` (14 days, sequential) | Poster grid. Rewind / FF opens When / Venue / Promote filters. OK opens details |
| Community | `{city}/api/community/listings` and `/acts` | Poster grid. Rewind / FF opens Category / Promote. Reply / post / sign-up → website hint |
| Promote | Public prices from the city `/plans` page | Thin orange selector + product card. Sign-up stays on the website |
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

`make screenshots` drives the sideloaded channel over the network and writes six 1920×1080 JPEGs to `out/store-screens/` for the Channel Store listing. The TV remote will move by itself; leave it alone until it finishes.

`make deeplink` launches the sideloaded channel straight into Brighton live (`contentId=brighton`, `mediaType=live`).

## Channel Store packaging

You do **not** need TTNS backend credentials. You need a **Roku developer account** that belongs to TTNS, plus the **packaging password** from `genkey` on a linked developer box.

The short version:

1. Sideload this build.
2. Generate and save a signing key (`telnet <roku-ip> 8080`, then `genkey`).
3. Set `ROKU_SIGN_PASSWORD` in `.env`.
4. `make package` and download the signed `.pkg`.
5. Upload that `.pkg` in the [Roku Developer Dashboard](https://developer.roku.com).

The full checklist — Dashboard beta vs public Streaming Store, listing copy, screenshots, and certification gaps — is in [docs/STORE.md](docs/STORE.md).

Store assets this repo already generates:

- Channel posters: `images/channel-poster_*.png` (540×405 / 290×218 / 246×140)
- Splash: `images/splash-screen_*.jpg`

You still need 1920×1080 Channel Store screenshots from a real Roku (home, player, gigs, community, promote).

## Project layout

```
manifest
source/           BrightScript helpers (stations, registry, dates, chat text)
components/       SceneGraph screens + HTTP / schedule / community tasks
images/           splash, posters, transparent logo, spinner
scripts/          image render + API smoke check
docs/             notes, BrightScript gotchas, Channel Store checklist
```

Add a new city in `source/stations.brs` (`id`, stream URL, `https://<city>.ttns.fm`). The schedule and community tasks already use the station’s `apiBaseUrl`.

## Privacy / TV-safe rules

- No login, no forms, no payments on the TV.
- Community payloads can include emails; the channel drops those fields and only shows title, category, city, asking price, and description.
- Gig details point at the city site, not the raw ticket vendor URL.

## Docs

- [Beta notes and known limits](docs/NOTES.md)
- [Channel Store release checklist](docs/STORE.md)
- [Changelog](CHANGELOG.md)

## License

Private TTNS channel. `v0.2.2-beta` is the build submitted to the Roku Streaming Store; it is not live in Search until Roku finishes review.
