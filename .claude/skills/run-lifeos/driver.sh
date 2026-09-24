#!/usr/bin/env bash
# Build, launch and drive LifeOS in the iOS Simulator. See SKILL.md.
#   driver.sh run                  build app, boot sim, install, launch, screenshot
#   driver.sh drive "<steps>"      run a DRIVER_STEPS script via XCUITest (taps + shots)
#   driver.sh shot [name]          screenshot whatever is on screen now
#   driver.sh reset                uninstall the app (wipes SwiftData -> reseeds next launch)
#   driver.sh stop                 terminate the app
# Env: SIM (device name, default "iPhone 17 Pro"), OUT (artifacts dir).
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"
SIM="${SIM:-iPhone 17 Pro}"
OUT="${OUT:-${TMPDIR:-/tmp}/lifeos-driver}"
BUNDLE_ID=com.riasaxena.lifeos
# xcode-select may point at CommandLineTools (no simctl / iOS SDK). Don't
# change the system setting - just pick Xcode.app for this process.
if [[ -z "${DEVELOPER_DIR:-}" && "$(xcode-select -p)" == *CommandLineTools* ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

log() { echo "[driver] $*" >&2; }

udid() {
  local id
  id=$(xcrun simctl list devices available | awk -v n="$SIM" '
    { line=$0; sub(/^ +/, "", line) }
    index(line, n" (") == 1 { match(line, /\(([0-9A-F-]{36})\)/); print substr(line, RSTART+1, 36); exit }')
  [[ -n "$id" ]] || { log "no available simulator named '$SIM' (xcrun simctl list devices available)"; exit 1; }
  echo "$id"
}

boot() {
  local u; u=$(udid)
  xcrun simctl boot "$u" 2>/dev/null || true   # "already booted" is fine
  open -a Simulator
  xcrun simctl bootstatus "$u" -b >/dev/null
  echo "$u"
}

gen() {
  command -v xcodegen >/dev/null || { log "installing xcodegen"; brew install xcodegen; }
  mkdir -p "$OUT/proj"
  (cd "$SKILL_DIR" && LIFEOS_ROOT="$ROOT" xcodegen generate --quiet --spec driver.yml --project "$OUT/proj")
}

xb() {  # xcodebuild with output reduced to errors + result line; full log in $OUT
  local logf="$OUT/xcodebuild.log"
  if ! xcodebuild -project "$OUT/proj/LifeOS.xcodeproj" -scheme LifeOSDriver \
      -destination "id=$U" -derivedDataPath "$OUT/dd" CODE_SIGNING_ALLOWED=NO "$@" >"$logf" 2>&1; then
    grep -E "error:|DRIVER|\*\* .* FAILED" "$logf" | head -40 >&2
    log "xcodebuild failed - full log: $logf"; return 1
  fi
  grep -E "DRIVER (step|shot|tree)|\*\* .* SUCCEEDED" "$logf" | sed 's/^.*DRIVER/DRIVER/' >&2 || true
}

cmd="${1:-run}"; shift || true
mkdir -p "$OUT"
case "$cmd" in
  run)
    gen; U=$(boot)
    xb build
    xcrun simctl install "$U" "$OUT/dd/Build/Products/Debug-iphonesimulator/LifeOS.app"
    xcrun simctl terminate "$U" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$U" "$BUNDLE_ID" >/dev/null
    sleep 4
    xcrun simctl io "$U" screenshot "$OUT/launch.png" >/dev/null 2>&1
    log "launched; screenshot: $OUT/launch.png"
    ;;
  drive)
    steps="${1:?usage: driver.sh drive \"tab:Health;shot:health\"}"
    gen; U=$(boot)
    mkdir -p "$OUT/shots"
    TEST_RUNNER_DRIVER_STEPS="$steps" TEST_RUNNER_SHOT_DIR="$OUT/shots" xb test
    log "screenshots in $OUT/shots"
    ;;
  shot)
    U=$(udid); xcrun simctl io "$U" screenshot "$OUT/${1:-shot}.png" >/dev/null 2>&1
    echo "$OUT/${1:-shot}.png"
    ;;
  reset) U=$(udid); xcrun simctl uninstall "$U" "$BUNDLE_ID"; log "uninstalled (data wiped)";;
  stop)  U=$(udid); xcrun simctl terminate "$U" "$BUNDLE_ID" || true;;
  *) sed -n '2,9p' "$0"; exit 1;;
esac
