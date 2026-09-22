# LifeOS — Product Requirements Document

**Author:** Ria Saxena
**Status:** Draft v1
**Platform:** iOS (SwiftUI), personal/sideloaded — not App Store bound
**Last updated:** 2026-09-21

## 1. Problem Statement

Ria captures a lot (notes, meeting notes on paper, ideas) but has no reliable
system for turning captured things into completed things. To-do lists are the
one format that's actually worked for her historically. Specific pain points
this app targets:

- Recurring personal care (medicine, workouts) gets missed because nothing
  reminds her or gives her a simple daily check-off.
- She intends to call friends and reconnect but the intention never turns
  into an actual call — there's no prompt or rotation.
- Same problem on the work side: networking/relationship-building calls and
  emails get thought about, not done.
- Commute time (BART, twice a day) is dead time that could go toward hobbies
  she wants to build (evening) or career development (morning), but nothing
  structures that time for her.

## 2. Goals

- Give Ria one place, on her phone, that turns "things I mean to do" into
  simple daily/weekly checklists she'll actually look at.
- Make health tracking (meds + workouts) a 10-second daily action, not a log
  she has to remember to open and fill in thoughtfully.
- Turn "I should call so-and-so" into a lightweight rotating queue instead of
  relying on memory.
- Use the two BART commutes (morning / evening) as the natural trigger for
  two different kinds of self-investment: career input in the morning,
  creative/hobby output in the evening.

## 3. Non-Goals (v1)

- No App Store distribution — sideloaded via Xcode onto her own iPhone.
- No multi-user / account system — single local user, local data only.
- No real Oura Ring integration in v1 (see Future Upgrades).
- No backend/server — everything stored on-device (v1).

## 4. Information Architecture

Tab bar with 5 tabs, **Home in the center position** (the tab bar order is
Health, Social, Home, Hobbies, Career Prep) since it's the tab she'll return
to most:

1. **Health**
2. **Social**
3. **Home** — the default landing tab
4. **Hobbies** (commute-integrated)
5. **Career Prep** (commute-integrated)

Each tab is designed around Ria's actual routine rather than being a generic
tracker, so the day-to-day flow is: open the app → Home, a scrollable list of
today's tasks pulled from every area; morning commute → tap into Career Prep
if she wants the full queue; health check-ins happen whenever she takes meds
/ finishes a workout; social nudges surface as a short rotating queue;
evening commute → Hobbies tab (or just check it off from Home).

---

## 5. Tab 0 — Home

### 5.1 Purpose
A single scrollable "Today" list that pulls one or two actionable items from
each of the other tabs, so opening the app answers "what do I still need to
do today" without tapping into four separate tabs. This is deliberately a
**task list, not a set of links out to the other tabs** — the whole point is
that to-do lists are the one format that's worked for Ria historically, so
Home behaves like one.

### 5.2 Core Features
- Grouped by rough time of day (Morning / Anytime / This evening) rather than
  by app tab — mirrors how she'd actually think about her day.
- Each row: a checkbox, a small icon indicating which area it's from (Health,
  Social, Hobbies, Career Prep), a title, and a one-line context/subtitle
  (e.g. "Health · by 8:00 PM", "Social · overdue, 5 weeks").
- Tapping the checkbox completes the item in place — no navigation required.
  Completed items stay visible (struck-through, dimmed) rather than
  disappearing, so the list still reads as "here's my whole day," not just
  "here's what's left."
- A progress summary at the top ("2 of 6 done today") plus the current
  Health streak, so the emotionally motivating stuff is visible immediately.
- Items are generated from each tab's own data (an unchecked medicine, an
  overdue contact, tonight's hobby suggestion, the next Career Prep queue
  item) — Home has no data model of its own; it's a computed view over the
  other four tabs' data.

### 5.3 Design Note
Earlier drafts of this tab were a set of summary cards that linked into each
tab. That's explicitly **not** what this screen should do — the whole reason
Home exists is to remove the need to go tab-hopping. Deep links from Home are
fine as a v2 nicety (e.g. long-press to jump to a tab) but the primary
interaction is completing the checklist right there.

---

## 6. Tab 1 — Health

### 6.1 Purpose
Seamless daily tracking of medicine adherence and workout activity. Optimized
for minimum friction — this should never feel like "filling out a log."

### 6.2 Core Features

**Medicine tracking**
- Today view shows each medicine as a card/row with a single tap to mark
  "Taken" (with timestamp captured automatically).
- Support for recurring schedules (e.g., daily, specific days of week).
- Visual state: taken (checked, greyed/green) vs. not yet taken (highlighted)
  vs. missed (past its usual time and still unchecked, shown in a "missed"
  state — not punitive, just informational).

**Streak**
- A streak banner at the top of the Health tab ("🔥 12-day streak") counts
  consecutive days where meds were taken *and* a workout (or an explicit rest
  day) was logged — both halves matter, not just one.
- Tapping the streak banner opens a **Streak Detail** screen: current streak,
  longest streak on record, a rolling 30-day adherence percentage, and a
  4-week calendar/heatmap grid so she can see the shape of her consistency,
  not just a number.
- Streak logic is forgiving by design (see Cross-Cutting Design Principles —
  no guilt-driven UI): a broken streak resets the counter but the history
  stays visible in the detail view rather than being erased or shamed.

**Workout tracking**
- One-tap logging of today's workout type. Preset categories based on her
  actual routine:
  - Weight lifting → sub-picker: Arms, Legs, Back/Biceps
  - Hot yoga
  - Walk
  - (Rest day / none — explicit option so skipping is a choice, not an
    absence)
- Optional free-text note field (collapsed by default, so logging stays fast).
- Weekly view showing which days had what type of activity (simple calendar
  strip or dot-per-day), so she can see patterns (e.g., "no legs day in 2
  weeks").

**Home/Today state for this tab**
- A single "Today" screen with meds at top, workout logging below — both
  completable in a few taps total.

### 6.3 Data Model (conceptual)
- `Medicine`: name, dosage (optional), schedule (days/times), reminder time(s)
- `MedicineLog`: medicineId, date, takenAt (timestamp) or missed
- `WorkoutType`: enum — weightliftingArms, weightliftingLegs,
  weightliftingBackBiceps, hotYoga, walk, rest
- `WorkoutLog`: date, type, note (optional), duration (optional)
- `Streak` (computed, not stored directly): current count, longest count —
  derived from `MedicineLog` + `WorkoutLog` each time the Health tab or
  Streak Detail screen is opened, rather than tracked as separate mutable
  state that could drift out of sync.

### 6.4 Future Upgrade
- **Oura Ring integration**: pull sleep, readiness, and activity data via
  Oura's API to auto-suggest workout type/intensity, auto-detect walks, and
  correlate medicine adherence with sleep/recovery trends. Flagged as v2 —
  not built in v1, but the data model should stay loosely compatible (e.g.,
  `WorkoutLog.source: manual | oura` field reserved for later).

---

## 7. Tab 2 — Social

### 7.1 Purpose
Turn "I keep meaning to call people" into a lightweight rotating system for
both personal relationships (friends) and professional relationships
(networking) — same underlying mechanic, two contexts.

### 7.2 Core Features

**Friends — Rotating Call List**
- A list of friends she wants to stay in touch with, each with a target
  cadence (e.g., every 2 weeks, monthly).
- The app surfaces a short rotating queue: "Who to catch up with" — sorted by
  who's most overdue.
- One tap to log "Called [name]" which resets their timer and moves them to
  the back of the queue.
- Optional short note per call (what you talked about, so next time she has
  context — small but meaningful for maintaining friendships).

**Work Networking**
- Same mechanic, separate list: contacts to network with (former colleagues,
  people met at events, etc.).
- Each contact tagged with preferred medium: Call / Email.
- Log action captures medium used + optional note (e.g., "followed up on job
  referral").
- Distinct from Friends list because the tone/purpose differs (career
  relationship maintenance vs. personal), but reuses the same UI pattern.

### 7.3 Add Person Flow
- A "+" button in the Social tab header opens an **Add Person** form:
  Name, Category (Friend / Work contact), Preferred way to reach out
  (Call / Email), check-in cadence (Weekly / 2 weeks / Monthly, extensible),
  and an optional note.
- Saving adds them to the appropriate queue immediately, positioned by
  cadence as if they were just contacted (so a newly added person doesn't
  jump straight to the top as "overdue").
- Also reachable as a dashed "Add someone to the list" row at the bottom of
  the queue, so the affordance is visible without needing to notice the
  header button.

### 7.4 Data Model (conceptual)
- `Contact`: name, category (friend | networking), preferredMedium (call |
  email), cadenceDays, lastContactedAt
- `ContactLog`: contactId, date, medium, note (optional)

### 7.5 Design Note
The "queue" is the key UX idea here — she shouldn't have to remember to open
this tab and think about who to call. The tab itself should always answer
"who's next" with zero thinking required.

---

## 8. Tab 3 — Hobbies (Evening Commute)

### 8.1 Purpose
Use the BART evening commute as a built-in trigger to invest in creative
hobbies — both existing ones and ones she's wanted to try — rather than
letting that time default to passive scrolling.

### 8.2 Core Features
- A list of hobbies (current + "want to try"), each tagged as
  commute-friendly or not (some creative hobbies work well in a BART seat —
  sketching, writing, reading a craft book, learning an instrument app,
  language app, etc.; others don't).
- A simple "Evening commute suggestion" surface: when opened, the app
  suggests one commute-friendly hobby to spend today's ride on (rotating
  through the list, or weighted toward ones she hasn't done recently).
- One-tap log: "Did it today" — builds a lightweight streak/history per
  hobby, same low-friction pattern as Health.
- Space to jot idea/progress notes per hobby (e.g., "sketch #4 — working on
  shading").

### 8.3 Add Hobby Flow
- A "+" button in the Hobbies tab header (and a dashed "Add a hobby" row at
  the bottom of the list) opens an **Add Hobby** form: Name, Status
  (Want to try / Already active), and a Commute-friendly toggle with a short
  explainer that commute-friendly hobbies are the ones eligible for the
  evening "Tonight's pick" suggestion. Optional notes field.
- New "want to try" hobbies are eligible for suggestion the same as active
  ones — the point is to actually get her to start them, not just log ones
  she's already doing.

### 8.4 Data Model (conceptual)
- `Hobby`: name, status (active | wantToTry), commuteFriendly (bool), notes
- `HobbyLog`: hobbyId, date, note (optional)

### 8.5 Open Question for v1 Design
Whether "commute-friendly" hobbies need any special handling (e.g., surfaced
automatically based on time of day / detected commute) or whether a manual
"suggest something for tonight" button is enough for v1. Recommend starting
manual — automatic commute-detection is a good future upgrade (could pair
with location/calendar in a later version), not required for v1.

---

## 9. Tab 4 — Career Prep (Morning Commute)

### 9.1 Purpose
Use the morning BART commute as protected time for interview prep and
staying current in her field — reading articles or listening to podcasts —
without having to decide in the moment what to consume.

### 9.2 Core Features
- A queue of articles (links) and podcast episodes she wants to get through,
  tagged by type (Article | Podcast) and topic (e.g., Interview Prep,
  Industry News, Technical).
- A "This morning" surface: shows the next 1–2 items from the queue, so
  opening the app on the train answers "what should I read/listen to" with
  no decision needed.
- One-tap "Done" to mark an item complete and advance the queue; optional
  short note (e.g., a takeaway, or an interview-prep talking point that came
  from reading the article).
- Quick-add: ability to drop in a new article link or podcast episode
  whenever she comes across one (so capture stays low-friction — this is the
  same instinct that produces her thousands of notes, but funneled into one
  queue instead of scattered).

### 9.3 Add Item Flow
- The "+" button in the Career Prep header (also offered inline as a dashed
  "Add an article or podcast" row) opens an **Add Item** form: Type
  (Article / Podcast), Title, an optional Link field to paste a URL, and a
  Topic tag (Interview Prep / Industry News / Technical, extensible).
- This is the funnel for the same instinct that produces Ria's thousands of
  scattered notes — when she comes across something interesting mid-day, it
  goes straight into this queue instead of a note she'll never revisit.

### 9.4 Data Model (conceptual)
- `PrepItem`: title, type (article | podcast), url (optional), topic, status
  (queued | done), addedAt, completedAt
- Optional: link out to Podcasts/Safari app for actually consuming the
  content — this app manages the queue and tracking, not playback.

---

## 10. Cross-Cutting Design Principles

1. **Logging something should take one or two taps, not a form.** Every tab's
   primary action is a single tap from the tab's home state.
2. **The app should always be able to answer "what's next" without her
   thinking about it** — meds due, who to call, what hobby tonight, what to
   read this morning. This is the core fix for the "capture but never
   follow up" pattern.
3. **No guilt-driven UI.** Missed days/streak breaks are shown factually, not
   punitively — this needs to be sustainable, not another system she
   abandons.
4. **Local-first.** All data stored on-device (e.g., SwiftData or Core Data)
   for v1 — no account creation, no server dependency, nothing to maintain
   beyond the app itself.

## 11. Success Criteria (how she'll know it's working)

- Medicine adherence and workout logging happen same-day, most days, without
  her having to "remember to log it later."
- At least one friend + one work contact call/email per week, driven by the
  queue rather than spontaneous memory.
- Evening commute hobby suggestion gets used a few times a week.
- Morning commute queue stays non-empty (she's adding faster than or equal to
  consuming) and she's completing prep items regularly ahead of interviews.

## 12. Future Upgrades (Backlog, not v1)

- **Oura Ring integration** (Health tab): pull sleep/readiness/activity data
  automatically; auto-suggest workout intensity; correlate recovery with
  medicine adherence.
- Push notifications / local reminders for medicine times.
- Automatic commute detection (location or calendar-based) to auto-surface
  the Hobbies or Career Prep "today" card at the right time.
- iCloud sync across devices (currently single-device, on-phone only).
- Podcast app deep-linking (open directly in Apple Podcasts / Spotify from a
  queued item).
