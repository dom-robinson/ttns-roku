#!/usr/bin/env python3
"""Check the public TTNS endpoints this Roku channel depends on."""

from __future__ import annotations

import json
import ssl
import urllib.request
from datetime import date

UA = "TTNS-Roku-smoke/1.0"


def get(url: str):
    req = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": UA})
    context = ssl._create_unverified_context()
    with urllib.request.urlopen(req, timeout=20, context=context) as resp:
        return resp.status, json.loads(resp.read().decode("utf-8"))


def main() -> int:
    failed = 0
    today = date.today().isoformat()
    checks = [
        ("nowplaying", "https://nowplaying.ttns.uk/trackinfo/current", lambda d: bool(d.get("track") or d.get("streamTrack"))),
        ("canvas", "https://canvas.ttns.uk/api/state.php", lambda d: bool(((d.get("state") or {}).get("canvas") or {}).get("url"))),
        ("brighton schedule", f"https://brighton.ttns.fm/api/schedule?date={today}&public=true", lambda d: isinstance(d, list) and "schedule" in d[0]),
        ("brighton listings", "https://brighton.ttns.fm/api/community/listings?limit=5", lambda d: d.get("ok") is True and "listings" in d),
        ("brighton acts", "https://brighton.ttns.fm/api/community/acts?limit=5", lambda d: d.get("ok") is True and "acts" in d),
    ]
    for name, url, ok in checks:
        try:
            status, data = get(url)
            if status != 200 or not ok(data):
                print(f"FAIL {name}: unexpected payload from {url}")
                failed += 1
            else:
                print(f"ok   {name}")
        except Exception as exc:
            print(f"FAIL {name}: {exc}")
            failed += 1
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
