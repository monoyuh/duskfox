# Duskfox

Personal Firefox **140.17.0 ESR** fork. Built for one machine and one goal:
**raw speed**.

- Base: `mozilla-firefox/firefox` @ `FIREFOX_140_17_0esr_RELEASE`
- Target: Intel Core i5-4670K (Haswell) — `-march=haswell`, AVX2/FMA/AES-NI
- Native **vertical tabs** (no extension)
- Zero telemetry / Pocket / sponsored content / Firefox Suggest / AI / Shopping
- Security deliberately traded for speed (no Safe Browsing, no OCSP, no tracker
  blocking, no cookie partitioning, no DoH, no hardening).
- No adblocker bundled (by request).
- Custom **Duskfox** identity throughout: logo, wordmark, window title,
  `application.ini`, `--version`.
- Compiler: clang 19, ThinLTO, `-O3`, jemalloc, Rust `target-cpu=haswell`.

## Layout

```
duskfox/
  mozconfig              build configuration
  LICENSE                MPL 2.0 (prefs are derived from Mozilla's defaults)
  config/
    duskfox-prefs.js     all default prefs (pref() form)
    userContent.css      site dark-mode (Google) injected as page CSS
    branding/            Duskfox logo/wordmark art (icons + about-page PNGs)
  scripts/
    apply.sh             patch the source tree (idempotent): mozconfig,
                         prefs, branding, bookmark strip, version string
    build.sh             apply + ./mach build (foreground)
    start-build.sh       detached launcher (throttled by default)
    buildctl.sh          pause / resume / status / stop
    hold-awake.sh        block sleep/suspend while the build runs
  READ-ME-FIRST.txt      note shipped inside the friend tarball

  ref/                   downloaded reference prefs (local only, not in git)
```

## Build

```sh
# one-time: fetch the base source (not shipped in this repo)
curl -LO https://archive.mozilla.org/pub/firefox/releases/140.17.0esr/source/firefox-140.17.0esr.tar.xz
tar -C /mnt/build -xf firefox-140.17.0esr.tar.xz   # -> /mnt/build/firefox

# detached, full speed (nice 0, -j4)
DUSKFOX_FULL=1 scripts/start-build.sh

# detached, throttled (nice 19 + idle I/O, -j3) -> machine stays usable
scripts/start-build.sh

# foreground
scripts/build.sh

# artifact lands in /mnt/build/firefox/obj-*/dist/bin/duskfox
scripts/buildctl.sh status
```

**Why the launcher exists:** `mach build` renices *itself* to 19 by default
(`--priority idle`). Full speed means `--priority normal` (nice 0). An
unprivileged process cannot lower nice again once mach has raised it, so the
mode must be chosen at launch.

## Notes / toggles

- `fission` (site isolation) left ON; content processes capped at 4.
- PGO is wired but off (see mozconfig `GEN_PGO`/`USE_PGO`). Enable for
  another ~10% at roughly 2x build time.
- Branding: the custom art lives in `config/branding/` and is copied into
  `browser/branding/duskfox/` by `scripts/apply.sh` (dist/bin symlinks mean
  icon changes need no rebuild; a name/version change does).
- Video: `media.webm.enabled=false` + `media.av1.enabled=false` hide VP9/AV1 so
  YouTube serves H.264 (avc1, itag 299), which the RX 480 hardware-decodes.
  Tradeoff: VP9/WebM `<video>` on other sites won't play. Both are one
  `about:config` toggle away.
- Prefs in `config/duskfox-prefs.js` are only *defaults*; anything can be
  overridden at runtime in `about:config` without a rebuild.
- Sleep is blocked while a build runs, via an elogind inhibitor held by
  `scripts/hold-awake.sh` (auto-releases when `build.pid` dies; `stop` to
  release early). Because agent/build shells sit outside a login session,
  polkit treats them as "any" (`allow_any=no`), so
  `/etc/polkit-1/rules.d/49-duskfox-inhibit.rules` grants `wheel` the right to
  hold login1 inhibitors.
- X was set to `xset s off -dpms` (monitor never blanks). Revert with
  `xset s 600 600; xset dpms 600 600 600`.

## Legal / trademarks

Unofficial personal project — not affiliated with or endorsed by Mozilla.
"Firefox" and "Mozilla" are trademarks of the Mozilla Foundation.

This repo ships configuration, scripts and branding only: no Firefox source
code, no binaries. Prefs derived from Mozilla's default prefs are licensed
under the Mozilla Public License 2.0 — see `LICENSE`.

The shipped identity is Duskfox end to end: `Name=Duskfox`,
`MOZ_APP_VENDOR=Duskfox`, custom logo and wordmark, and
`duskfox --version` printing `Duskfox <version>`. The only survival of the
old words is the standard Gecko compatibility token in the user agent
(`Mozilla/5.0 … Firefox/…`) — every fork keeps those, because plenty of
sites break without them.
