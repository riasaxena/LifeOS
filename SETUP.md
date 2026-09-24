# Building LifeOS in Xcode

The Swift source is checked in, but the `.xcodeproj` itself is generated
with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`
rather than committed, so the project file never rot-diffs across machines.

## One-time setup

```bash
brew install xcodegen
```

## Every time you pull new source files

```bash
cd LifeOS
xcodegen generate
open LifeOS.xcodeproj
```

`xcodegen generate` re-scans `App/Sources` and rebuilds `LifeOS.xcodeproj`
to match, so run it again any time files are added or removed (a plain
edit to an existing file doesn't need a regenerate).

## First run

1. Open `LifeOS.xcodeproj`.
2. Select the `LifeOS` target -> **Signing & Capabilities** -> pick your
   personal team (Automatic signing is already on).
3. Plug in your iPhone (or pick a Simulator) and hit Run.
4. The app seeds itself with a few days of sample data on first launch
   (see `Support/SeedData.swift`) so all 5 tabs have something to show.

## Project layout

```
App/Sources/
  DesignSystem/   Theme.swift - colors + card style matching the mockups
  Domain/         SwiftData @Model types (Medicine, Workout, Contact, Hobby, PrepItem, ...)
  Repositories/   Protocol + SwiftData implementation per domain area
  ViewModels/     @Observable view models, one per tab (+ Home's aggregator)
  Views/          SwiftUI views, grouped by tab
  Support/        SeedData.swift
  LifeOSApp.swift App entry point + ModelContainer setup
  RootTabView.swift  Tab bar + where repositories get wired to view models
```

See `docs/SYSTEM_DESIGN.md` for why it's laid out this way (repository
protocols so a future cloud backend is a drop-in swap) and `docs/PRD.md`
for what each tab is for.
