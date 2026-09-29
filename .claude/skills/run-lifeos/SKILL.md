---
name: run-lifeos
description: Build, run, launch, screenshot and drive (tap tabs, fill forms) the LifeOS SwiftUI iOS app in the iOS Simulator on macOS. Use when asked to run/start the app, take a screenshot of a tab or screen, or confirm a UI change works in the real app.
---

# Run LifeOS

LifeOS is a SwiftUI + SwiftData iPhone app (no backend). It only runs on
macOS with Xcode, in the iOS Simulator. Agents drive it with
`.claude/skills/run-lifeos/driver.sh`. The script generates an Xcode project
with XcodeGen into a scratch directory. That project adds an XCUITest bundle
(`DriverUITests/`), which runs a step script you pass in: taps, typing and
screenshots. The product's `project.yml` never gets a test target.

All paths below are relative to the repo root.

## Prerequisites

- `/Applications/Xcode.app` (verified with Xcode 26.6) and an available
  `iPhone 17 Pro` simulator. Change it with `SIM="iPhone 17" ...`.
- `xcodegen`. The driver runs `brew install xcodegen` if it is missing.

## Run (agent path)

```bash
# Build, boot the simulator, install, launch, screenshot -> $TMPDIR/lifeos-driver/launch.png
.claude/skills/run-lifeos/driver.sh run

# Drive it: steps separated by ";". Screenshots/trees -> $TMPDIR/lifeos-driver/shots/
.claude/skills/run-lifeos/driver.sh drive "tab:Health;shot:health;tab:Social;shot:social;tab:Hobbies;shot:hobbies;tab:Career;shot:career"
.claude/skills/run-lifeos/driver.sh drive "tab:Health;text:1-day streak;shot:streak;back;tab:Hobbies;tree:hobbies"
.claude/skills/run-lifeos/driver.sh drive "tab:Hobbies;tap:Add a hobby;field:Name;type:Pottery;shot:add-hobby;tap:Cancel;shot:after-cancel"

# Add, then delete via long-press (every added item has a Delete context menu)
SIM="iPhone 17" .claude/skills/run-lifeos/driver.sh drive "tab:Health;tap:Add a medicine;field:Name;type:Magnesium;field:Dosage (optional);type:200mg;tap:Save;shot:med-added;hold:Magnesium;tap:Delete;shot:med-deleted"

# Screenshot whatever is on screen now (no rebuild)
.claude/skills/run-lifeos/driver.sh shot check
```

Steps (full list in `DriverUITests/DriverUITests.swift`):

| step | does |
|---|---|
| `tab:<Health\|Social\|Home\|Hobbies\|Career>` | tap a tab bar item |
| `tap:<label>` | tap a button by its label or identifier |
| `text:<label>` | tap a static text, e.g. the streak banner or a workout tile |
| `hold:<label>` | long-press a static text to open its context menu (then `tap:Delete`) |
| `field:<placeholder>` / `type:<text>` | focus a text field and type into it |
| `back` | tap the navigation bar back button |
| `shot:<name>` / `tree:<name>` | save a PNG or an accessibility dump to `shots/` |
| `wait:<secs>` | sleep |

When a tap fails ("no element for step"), run `tree:x` on that screen and
grep `shots/x.txt` for `Button`/`StaticText` labels. Each `drive` call
relaunches the app, rebuilds only what changed (about 30s warm), and prints
`** TEST SUCCEEDED **` when every step passed. The full log is at
`$TMPDIR/lifeos-driver/xcodebuild.log`.

Other commands: `driver.sh stop` terminates the app. `driver.sh reset`
uninstalls it, which **wipes all SwiftData data**, so the sample data from
`Support/SeedData.swift` is loaded again on the next driver launch. The user
may be using the same simulator by hand, so ask before running `reset`. For
flows that add or delete data, use a different simulator
(`SIM="iPhone 17"`) so the user's data stays untouched.

## Run (human path)

Follow `SETUP.md`: run `xcodegen generate`, `open LifeOS.xcodeproj`, then
press Run in Xcode.

## Gotchas

- **`xcode-select -p` may point to CommandLineTools.** Then there is no
  `simctl` and no iOS SDK. The driver exports
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for its own
  process only, and does not run `sudo xcode-select -s`.
- **Every `xcodegen generate` rewrites `App/Sources/Info.plist`.** It expands
  from an empty dict to the full CFBundle keys taken from `project.yml`'s
  `info:` section. That includes the driver's generate step, so expect that
  file to show as modified. Leave it alone; it is not your change.
- **Sample data is opt-in.** It loads only when the app is launched with
  `-seedSampleData`, and only into an empty store. Both `driver.sh run` and
  `drive` pass the flag. A plain Xcode/phone install starts empty by
  design. To see the empty state, install
  `$TMPDIR/lifeos-driver/dd/Build/Products/Debug-iphonesimulator/LifeOS.app`
  on a fresh simulator with `xcrun simctl install`, then run
  `xcrun simctl launch <udid> com.riasaxena.lifeos` without the flag.
  After anyone uses the app, screens stop matching `SeedData.swift`.
- **Buttons whose label includes an emoji don't match `tap:`.** Workout
  tiles are exposed as `"🧘, Hot Yoga"`, so use `text:Hot Yoga`.
- Buttons with only an icon expose their SF Symbol name as their
  identifier. For example, the Hobbies "+" button has identifier `plus` and
  label `Add`.
- `driver.sh drive` passes steps through xcodebuild's `TEST_RUNNER_` env
  prefix (`TEST_RUNNER_DRIVER_STEPS`, `TEST_RUNNER_SHOT_DIR`). The UI test
  writes PNGs straight to the host path, so no `.xcresult` extraction is
  needed.

## Troubleshooting

- `Build input file cannot be found: '.../App/Sources/Info.plist'`: happens
  when the project is generated outside the repo. XcodeGen rebases source
  paths but not `INFOPLIST_FILE`. `driver.yml` overrides it with
  `${LIFEOS_ROOT}`, which `driver.sh` sets, so run the driver instead of
  calling `xcodegen --spec driver.yml` yourself.
- `no available simulator named ...`: pick a name from
  `xcrun simctl list devices available` and pass `SIM="<name>"`.
