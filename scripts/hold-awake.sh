#!/usr/bin/env bash
# Hold an elogind inhibitor so the machine cannot suspend while the Duskfox
# build runs. The lock auto-releases the moment the build process exits.
#
#   scripts/hold-awake.sh start   acquire (detached, tied to build.pid)
#   scripts/hold-awake.sh stop    release now
#   scripts/hold-awake.sh status  show current locks
set -euo pipefail

DUSKFOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
PIDFILE="$DUSKFOX_DIR/build.pid"
HOLDER="$DUSKFOX_DIR/hold.pid"

# ---- inner mode: block until the build process is gone ---------------------
if [ "${1:-}" = "--hold" ]; then
  while kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; do sleep 20; done
  exit 0
fi

case "${1:-start}" in
  stop)
    if [ -f "$HOLDER" ]; then
      pgid="$(ps -o pgid= -p "$(cat "$HOLDER")" 2>/dev/null | tr -d ' ')"
      [ -n "$pgid" ] && kill -TERM -- "-$pgid" 2>/dev/null || true
      rm -f "$HOLDER"
      echo ">> sleep inhibitor released"
    else
      echo ">> no sleep inhibitor held"
    fi
    ;;
  start)
    if [ -f "$HOLDER" ] && kill -0 "$(cat "$HOLDER")" 2>/dev/null; then
      echo ">> already holding sleep inhibitor (pid $(cat "$HOLDER"))"
      exit 0
    fi
    export DUSKFOX_PIDFILE="$PIDFILE" DUSKFOX_HOLDER="$HOLDER" DUSKFOX_SELF="$SELF"
    setsid bash -c 'echo $$ >"$DUSKFOX_HOLDER"; exec elogind-inhibit --what=sleep:idle:handle-lid-switch:handle-suspend-key:handle-hibernate-key:handle-power-key --mode=block --who=Duskfox --why="unattended build in progress" "$DUSKFOX_SELF" --hold' >/dev/null 2>&1 &
    disown || true
    sleep 2
    if [ -f "$HOLDER" ] && kill -0 "$(cat "$HOLDER")" 2>/dev/null; then
      echo ">> sleep inhibitor active (pid $(cat "$HOLDER"))"
      elogind-inhibit --list --no-pager 2>/dev/null | head -6 || true
    else
      echo ">> FAILED to acquire sleep inhibitor"
      exit 1
    fi
    ;;
  status)
    elogind-inhibit --list --no-pager 2>/dev/null || echo "(none)"
    ;;
  *)
    echo "usage: hold-awake.sh {start|stop|status}"
    exit 1
    ;;
esac
