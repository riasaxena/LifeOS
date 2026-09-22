# LifeOS

A personal iOS app to help keep track of the scattered parts of day-to-day
life — health, relationships, hobbies, and career development — in one place
that's actually easy to keep up with.

Built for personal use only. Not distributed on the App Store — sideloaded
via Xcode onto a personal iPhone.

## Why

Notes get captured everywhere but rarely turned into action. To-do-list-style
checklists are the one format that's actually worked historically, so this
app leans into that: every tab is built around "what's next, right now" with
one-tap logging, rather than a log/journal you have to remember to fill out.

## The Tabs

Home sits in the center of the tab bar since it's the default landing screen;
the order left to right is Health, Social, **Home**, Hobbies, Career Prep.

| Tab | What it does |
|---|---|
| **Home** | A scrollable "Today" checklist pulling one or two actionable items from every other tab (meds due, who to call, tonight's hobby, this morning's read) — a task list, not a set of links out |
| **Health** | One-tap medicine adherence tracking + daily workout logging (weight lifting split by Arms/Legs/Back-Biceps, hot yoga, walks), plus a streak banner with a detail view (longest streak, 30-day adherence, 4-week heatmap) |
| **Social** | Rotating call list for friends (personal catch-ups) and a parallel list for work networking (calls/emails), with an Add Person flow |
| **Hobbies** | Creative hobbies (current + want-to-try) surfaced as a suggestion for the evening BART commute, with an Add Hobby flow |
| **Career Prep** | Queue of articles and podcasts for interview prep / industry reading, surfaced for the morning BART commute, with an Add Item flow |

See [`docs/PRD.md`](docs/PRD.md) for the full product spec, and the
[mockups artifact](https://claude.ai/artifact/7tuWyEE4KmrsbF38DiWKuJ) for a
clickable prototype of all 9 screens.

## Tech Stack

- **SwiftUI**, iOS native
- **SwiftData** (or Core Data) for local, on-device storage — no backend, no
  account system
- No third-party dependencies planned for v1

## Status

🚧 Design phase — PRD and mockups drafted, Xcode project not yet started.

## Getting Started (once code exists)

1. Open `LifeOS.xcodeproj` (or `.xcworkspace`) in Xcode.
2. Select your iPhone as the run destination.
3. Sign the app with your own Apple ID (free provisioning is fine for
   personal sideloading — apps expire after 7 days and need re-installing
   from Xcode; a paid Apple Developer account extends that to a year).
4. Build & run.

## Roadmap / Future Upgrades

- **Oura Ring integration** for the Health tab — pull sleep, readiness, and
  activity data automatically instead of manual workout logging, and
  correlate recovery with medicine adherence.
- Local push notifications for medicine reminders.
- Automatic commute detection to auto-surface the Hobbies / Career Prep
  "today" card at the right time of day.
- iCloud sync across devices.
- Deep-linking into Apple Podcasts / Spotify from queued Career Prep items.

## License

Personal project — no license, not for redistribution.
