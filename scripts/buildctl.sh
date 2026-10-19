#!/usr/bin/env bash
# Control the throttled Duskfox build: pause / resume / status / stop
set -euo pipefail

DUSKFOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIDFILE="$DUSKFOX_DIR/build.pid"
LOG="$DUSKFOX_DIR/build.log"

pgid_of() {
  ps -o pgid= -p "$1" 2>/dev/null | tr -d ' '
}

state() {  # stop | cont | dead
  [ -f "$PIDFILE" ] || { echo dead; return; }
  local pid; pid="$(cat "$PIDFILE")"
  kill -0 "$pid" 2>/dev/null || { echo dead; return; }
  if ps -o stat= -p "$pid" 2>/dev/null | grep -q '^T'; then echo stop; else echo cont; fi
}

case "${1:-status}" in
  pause)
    [ -f "$PIDFILE" ] || { echo "no build pidfile"; exit 1; }
    pgid="$(pgid_of "$(cat "$PIDFILE")")"
    [ -n "$pgid" ] || { echo "build not running"; exit 1; }
    kill -STOP -"$pgid"
    echo ">> BUILD PAUSED (pid $pgid). All 4 cores are yours."
    ;;
  resume|start)
    [ -f "$PIDFILE" ] || { echo "no build pidfile"; exit 1; }
    pgid="$(pgid_of "$(cat "$PIDFILE")")"
    [ -n "$pgid" ] || { echo "build not running"; exit 1; }
    kill -CONT -"$pgid"
    echo ">> BUILD RESUMED (pid $pgid) at nice 19."
    ;;
  stop|kill)
    [ -f "$PIDFILE" ] || { echo "no build pidfile"; exit 1; }
    pgid="$(pgid_of "$(cat "$PIDFILE")")"
    [ -n "$pgid" ] || { echo "build not running"; exit 1; }
    kill -CONT -"$pgid" 2>/dev/null || true
    kill -TERM -"$pgid"
    echo ">> build stopped"
    ;;
  status)
    s="$(state)"
    echo "state: $s"
    case "$s" in
      dead) echo "build not running" ;;
      stop) echo "build is PAUSED - resume with: scripts/buildctl.sh resume" ;;
      cont) echo "build is RUNNING (nice $(ps -o ni= -p "$(cat "$PIDFILE")" 2>/dev/null | tr -d ' '))" ;;
    esac
    echo "--- last log lines ---"
    tail -5 "$LOG" 2>/dev/null || true
    ;;
  *)
    echo "usage: buildctl.sh {pause|resume|status|stop}"
    exit 1
    ;;
esac
