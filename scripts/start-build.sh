#!/usr/bin/env bash
# Start the Duskfox build.
#   default:            throttled (nice 19, idle I/O, -j3) -> machine stays usable
#   DUSKFOX_FULL=1:     full speed, normal priority (-j4, no nice/ionice)
# Control it with scripts/buildctl.sh {pause|resume|status|stop}
set -euo pipefail

DUSKFOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${DUSKFOX_SRC:-/mnt/build/firefox}"
PIDFILE="$DUSKFOX_DIR/build.pid"
LOG="$DUSKFOX_DIR/build.log"

export PATH="$HOME/.cargo/bin:$PATH"
export MOZCONFIG="$SRC/mozconfig"
export MOZBUILD_STATE_PATH="${MOZBUILD_STATE_PATH:-/home/mono/.mozbuild}"
export DUSKFOX_PIDFILE="$PIDFILE"
export DUSKFOX_LOG="$LOG"

cd "$SRC"
"$DUSKFOX_DIR/scripts/apply.sh"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo ">> build already running (pid $(cat "$PIDFILE"))"
  exit 0
fi

# NB: mach renices *itself* to 19 by default (--priority idle). Full speed
# therefore means passing --priority normal so it stays at nice 0.
if [ "${DUSKFOX_FULL:-0}" = "1" ]; then
  BUILD_CMD='exec /usr/bin/python3.11 ./mach build --priority normal'
  echo ">> mode: FULL SPEED (nice 0, -j4)"
else
  BUILD_CMD='exec ionice -c 3 /usr/bin/python3.11 ./mach build --priority idle'
  echo ">> mode: THROTTLED (nice 19 via mach, ionice -c3, -j3)"
fi

# new session/process group, so buildctl.sh can STOP/CONT the whole tree.
# the inner shell records its own PID first, then execs (PID unchanged).
setsid bash -c 'echo $$ >"$DUSKFOX_PIDFILE"; '"$BUILD_CMD"' >>"$DUSKFOX_LOG" 2>&1' &
disown || true

sleep 2
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo ">> build started: pid $(cat "$PIDFILE")"
  echo ">> log: $LOG"
  echo ">> pause anytime:  scripts/buildctl.sh pause"
  # keep the machine from suspending for as long as the build lives
  "$DUSKFOX_DIR/scripts/hold-awake.sh" start || true
else
  echo ">> build failed to start; see $LOG"
  exit 1
fi
