#!/usr/bin/env bash
# Apply all Duskfox customisations to the Firefox source tree.
# Idempotent: safe to run multiple times.
set -euo pipefail

DUSKFOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${DUSKFOX_SRC:-/mnt/build/firefox}"

echo ">> Duskfox dir : $DUSKFOX_DIR"
echo ">> Source tree : $SRC"

[ -d "$SRC/browser" ] || { echo "ERROR: $SRC does not look like a Firefox tree"; exit 1; }

# --- 1. mozconfig -----------------------------------------------------------
cp -f "$DUSKFOX_DIR/mozconfig" "$SRC/mozconfig"
echo ">> installed mozconfig"

# --- 2. branding ------------------------------------------------------------
if [ ! -d "$SRC/browser/branding/duskfox" ]; then
  cp -a "$SRC/browser/branding/unofficial" "$SRC/browser/branding/duskfox"
  echo ">> created branding/duskfox from unofficial"
fi
echo ">> branding present (run branding edits from repo if missing)"

# --- 3. default prefs (append to firefox.js, idempotent) --------------------
FF_JS="$SRC/browser/app/profile/firefox.js"
MARKER="// ==== DUSKFOX DEFAULTS ===="
if grep -qF "$MARKER" "$FF_JS"; then
  # replace everything from the marker to EOF with the current prefs
  sed -i "/^${MARKER//\//\\/}/,\$d" "$FF_JS"
  echo ">> removed previous Duskfox prefs block"
fi
{
  echo ""
  echo "$MARKER"
  cat "$DUSKFOX_DIR/config/duskfox-prefs.js"
} >> "$FF_JS"
echo ">> appended Duskfox prefs to firefox.js"

# --- 4. strip default bookmarks (bloat) ------------------------------------
BM="$SRC/browser/locales/en-US/profile/bookmarks.inc"
if [ -f "$BM" ] && ! grep -qF "DUSKFOX-EMPTIED" "$BM"; then
  cp "$BM" "$BM.orig"
  printf '<!-- DUSKFOX-EMPTIED -->\n' > "$BM"
  echo ">> emptied default bookmarks"
fi

# --- 5. branding assets -----------------------------------------------------
BRAND_SRC="$DUSKFOX_DIR/config/branding"
BRAND_DST="$SRC/browser/branding/duskfox"
if [ -d "$BRAND_SRC" ]; then
  cp -a "$BRAND_SRC/." "$BRAND_DST/"
  echo ">> installed Duskfox branding assets"
fi

# --- 6. --version string: drop the vendor token (vendor == product name) ----
APP_RUNNER="$SRC/toolkit/xre/nsAppRunner.cpp"
if grep -qF 'DUSKFOX: keep --version' "$APP_RUNNER"; then
  echo ">> version-string patch already applied"
else
  python3 - "$APP_RUNNER" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path) as f:
    src = f.read()

old = '''  if (gAppData->vendor && *gAppData->vendor) {
    printf("%s ", (const char*)gAppData->vendor);
  }
'''
new = '''  // DUSKFOX: keep --version free of the vendor token. vendor == product
  // name here ("Duskfox"), so printing both would yield "Duskfox Duskfox".
  if (gAppData->vendor && *gAppData->vendor &&
      strcmp(gAppData->vendor, gAppData->name) != 0) {
    printf("%s ", (const char*)gAppData->vendor);
  }
'''

count = src.count(old)
if count != 2:
    sys.exit(
        "unexpected nsAppRunner.cpp layout: "
        f"found {count} vendor-print guards, expected 2"
    )
with open(path, "w") as f:
    f.write(src.replace(old, new))
print(f">> patched {count} version-print sites (DumpVersion/DumpFullVersion)")
PYEOF
fi

# --- 7. vendor: set MOZ_APP_VENDOR at its only accepted origin ---------------
# configure refuses MOZ_APP_VENDOR from mozconfig / env; browser/moz.configure
# implies the default ("Mozilla"), so override it there.
BROWSER_CONF="$SRC/browser/moz.configure"
if grep -qF 'DUSKFOX: vendor' "$BROWSER_CONF"; then
  echo ">> vendor imply patch already applied"
else
  python3 - "$BROWSER_CONF" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path) as f:
    src = f.read()

old = 'imply_option("MOZ_APP_VENDOR", "Mozilla")'
new = (
    '# DUSKFOX: vendor is only settable via imply (mozconfig/env origins are\n'
    '# rejected by configure), so override the default here.\n'
    'imply_option("MOZ_APP_VENDOR", "Duskfox")'
)

count = src.count(old)
if count != 1:
    sys.exit(
        "unexpected browser/moz.configure layout: "
        f"found {count} vendor implies, expected 1"
    )
with open(path, "w") as f:
    f.write(src.replace(old, new))
print(">> patched MOZ_APP_VENDOR imply -> Duskfox")
PYEOF
fi

echo ">> DONE."
