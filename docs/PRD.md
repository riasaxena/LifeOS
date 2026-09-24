# LifeOS — PRD

**Platform:** iOS (SwiftUI), personal / sideloaded — not on the App Store.

## Problem

Ria captures a lot but rarely follows up — notebooks and planners haven't
stuck, but to-do lists have. This app turns "things I mean to do" into
simple checklists across health, relationships, hobbies, and career prep.

## Goals

- Make medicine and workout logging a 10-second tap, not a log to remember.
- Turn "I should call so-and-so" into a rotating queue instead of memory.
- Use the two BART commutes as built-in triggers: career reading in the
  morning, a creative hobby in the evening.

## Non-Goals (v1)

- No App Store, no accounts, no backend — local-only, on one iPhone.

## The Tabs

Tab bar order: Health, Social, **Home**, Hobbies, Career Prep.

### Home
A scrollable "Today" checklist pulling one or two items from every other
tab (meds due, who to call, tonight's hobby, this morning's read), grouped
Morning / Anytime / Evening. **A task list, not a set of links out** —
checking something off happens right there, no navigating to another tab.
Shows a progress count and the current Health streak at the top.

### Health
- One-tap "Taken" per medicine, with recurring schedules.
- One-tap workout logging: Weights (Arms / Legs / Back-Biceps), Hot Yoga,
  Walk, or Rest.
- A streak banner (meds + a workout, both, each day) that opens a detail
  view: longest streak, 30-day adherence, a 4-week heatmap.
- *Future:* Oura Ring integration — auto-detect workouts, correlate
  recovery with adherence.

### Social
- Two rotating queues — **Friends** and **Work contacts** — each sorted by
  who's most overdue against a set cadence (weekly / 2 weeks / monthly).
- One tap to log a call/email, which resets their timer.
- "+" adds a person: name, category, preferred contact method, cadence.

### Hobbies
- A list of hobbies (active + want-to-try), each tagged commute-friendly
  or not.
- An evening "Tonight's pick" suggestion, one tap to log "did it."
- "+" adds a hobby: name, status, commute-friendly toggle.

### Career Prep
- A queue of articles/podcasts, tagged by topic (Interview Prep / Industry
  News / Technical).
- Shows the next 1–2 items so opening the app on the train answers "what do
  I read/listen to" with no decision needed.
- "+" quick-adds an item: type, title, link, topic.

## Design Principles

1. **One or two taps to log anything.**
2. **The app always answers "what's next"** without her having to think
   about it — that's the fix for capture-without-follow-up.
3. **No guilt-driven UI.** Missed days are shown factually, not punitively.
4. **Local-first.** SwiftData on-device for v1, no server dependency.

## Success Criteria

- Meds/workouts logged same-day, most days.
- At least one social touchpoint (friend or work) per week, driven by the
  queue, not memory.
- Career Prep queue stays non-empty; items get completed ahead of interviews.

## Future Upgrades (not v1)

- Oura Ring integration.
- Local push reminders for medicine times.
- Automatic commute detection to auto-surface Hobbies/Career Prep at the
  right time of day.
- Cloud sync + a Chrome extension — see [`SYSTEM_DESIGN.md`](SYSTEM_DESIGN.md).
