#!/usr/bin/env python3
"""Capture the six Channel Store screenshots from a sideloaded developer Roku.

Drives the living-room box over ECP (port 8060) and grabs frames from the
developer installer (plugin_inspect). Writes 1920x1080 JPEGs to out/store-screens/.

The TV remote will appear to move by itself. Sideload this build first:

    set -a && source .env && set +a
    make sideload
    make screenshots
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "out" / "store-screens"
SIZE = (1920, 1080)
BG = (10, 10, 10)

SHOTS = [
    "01-home.jpg",
    "02-listen.jpg",
    "03-gigs.jpg",
    "04-gig-detail.jpg",
    "05-community.jpg",
    "06-promote.jpg",
]


def env(name: str, default: str = "") -> str:
    return os.environ.get(name, default).strip()


def ecp(ip: str, path: str) -> None:
    url = f"http://{ip}:8060/{path.lstrip('/')}"
    req = urllib.request.Request(url, data=b"", method="POST")
    try:
        urllib.request.urlopen(req, timeout=8).read()
    except urllib.error.URLError as exc:
        raise SystemExit(f"ECP failed {url}: {exc}") from exc


def keypress(ip: str, key: str, pause: float = 0.45) -> None:
    ecp(ip, f"keypress/{key}")
    time.sleep(pause)


def wait(seconds: float, why: str) -> None:
    print(f"  wait {seconds:.0f}s ({why})")
    time.sleep(seconds)


def curl_digest(ip: str, password: str, args: list[str]) -> subprocess.CompletedProcess[bytes]:
    cmd = [
        "curl",
        "-sS",
        "--user",
        f"rokudev:{password}",
        "--digest",
        "--max-time",
        "30",
        *args,
    ]
    return subprocess.run(cmd, cwd=str(ROOT), capture_output=True)


def take_screenshot(ip: str, password: str, dest: Path) -> None:
    inspect = curl_digest(
        ip,
        password,
        [
            "-F",
            "mysubmit=Screenshot",
            "-F",
            "passwd=",
            f"http://{ip}/plugin_inspect",
        ],
    )
    if inspect.returncode != 0:
        err = inspect.stderr.decode("utf-8", "replace")
        raise SystemExit(f"plugin_inspect screenshot failed: {err}")
    html = inspect.stdout.decode("utf-8", "replace")
    match = re.search(r"pkgs/dev\.(jpg|png)", html, re.I)
    names = [f"pkgs/dev.{match.group(1)}"] if match else ["pkgs/dev.png", "pkgs/dev.jpg"]
    raw = b""
    used = ""
    for name in names:
        got = curl_digest(ip, password, [f"http://{ip}/{name}"])
        if got.returncode == 0 and got.stdout[:8] not in (b"", b"Not Found"):
            if got.stdout[:1] not in (b"<", b"N") and len(got.stdout) > 2000:
                raw = got.stdout
                used = name
                break
    if not raw:
        raise SystemExit(
            "Could not download pkgs/dev.jpg or pkgs/dev.png. "
            "Is a sideloaded channel running? Developer installer password set?"
        )
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(".raw")
    tmp.write_bytes(raw)
    im = Image.open(tmp).convert("RGB")
    canvas = Image.new("RGB", SIZE, BG)
    fitted = im.copy()
    fitted.thumbnail(SIZE, Image.Resampling.LANCZOS)
    x = (SIZE[0] - fitted.width) // 2
    y = (SIZE[1] - fitted.height) // 2
    canvas.paste(fitted, (x, y))
    canvas.save(dest, format="JPEG", quality=90)
    tmp.unlink(missing_ok=True)
    print(f"  wrote {dest}  ({im.size[0]}x{im.size[1]} from {used} -> 1920x1080)")


def main() -> int:
    ip = env("ROKU_DEV_TARGET")
    password = env("ROKU_DEV_PASSWORD")
    if not ip or not password:
        print("Set ROKU_DEV_TARGET and ROKU_DEV_PASSWORD in .env", file=sys.stderr)
        return 1

    gigs_wait = float(env("ROKU_SCREENSHOT_GIGS_WAIT", "40"))
    community_wait = float(env("ROKU_SCREENSHOT_COMMUNITY_WAIT", "12"))
    listen_wait = float(env("ROKU_SCREENSHOT_LISTEN_WAIT", "8"))

    print(f"Capturing store screenshots from {ip}")
    print("Leave the TV alone — this drives the remote over the network.")

    ecp(ip, "keypress/Home")
    wait(2, "Roku home")
    ecp(ip, "launch/dev")
    wait(5, "channel splash + home")

    OUT.mkdir(parents=True, exist_ok=True)
    take_screenshot(ip, password, OUT / SHOTS[0])

    keypress(ip, "Select", 0.2)
    wait(listen_wait, "listen live, canvas, chat")
    take_screenshot(ip, password, OUT / SHOTS[1])

    keypress(ip, "Back", 1.0)
    keypress(ip, "Right", 0.5)
    keypress(ip, "Select", 0.2)
    wait(gigs_wait, "gigs posters (sequential 14-day fetch)")
    take_screenshot(ip, password, OUT / SHOTS[2])

    keypress(ip, "Select", 0.2)
    wait(2.5, "gig detail")
    take_screenshot(ip, password, OUT / SHOTS[3])

    keypress(ip, "Back", 0.8)
    keypress(ip, "Back", 1.0)
    keypress(ip, "Right", 0.5)
    keypress(ip, "Select", 0.2)
    wait(community_wait, "community board")
    take_screenshot(ip, password, OUT / SHOTS[4])

    keypress(ip, "Back", 1.0)
    keypress(ip, "Left", 0.4)
    keypress(ip, "Left", 0.4)
    keypress(ip, "Down", 0.4)
    keypress(ip, "Select", 0.2)
    wait(2.0, "promote list")
    take_screenshot(ip, password, OUT / SHOTS[5])

    print("")
    print(f"Six JPEGs in {OUT}")
    print("Upload those under Store Assets in the Roku Developer Dashboard.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
