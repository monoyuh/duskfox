#!/usr/bin/env bash
# Build Duskfox. Usage: scripts/build.sh [extra mach args]
set -euo pipefail

DUSKFOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${DUSKFOX_SRC:-/mnt/build/firefox}"
export MOZCONFIG="$SRC/mozconfig"

# ccache/sccache lives on the scratch disk
export SCCACHE_DIR="/mnt/scratch/sccache"
# cbindgen is installed by `cargo install`
export PATH="$HOME/.cargo/bin:$PATH"

cd "$SRC"
"$DUSKFOX_DIR/scripts/apply.sh"

# mach is broken under the system python 3.14 (ast.Constant .s removal);
# Firefox 140 ESR expects <= 3.13, so pin 3.11 explicitly.
MACH_PY="${MACH_PYTHON:-/usr/bin/python3.11}"

echo ">> starting build with MOZCONFIG=$MOZCONFIG ($($MACH_PY --version))"
exec "$MACH_PY" ./mach build "$@"
