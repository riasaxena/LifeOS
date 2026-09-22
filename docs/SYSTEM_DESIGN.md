# LifeOS — System Design

**Status:** Draft v1
**Scope:** Architecture for the v1 local-only iOS app, designed so a future
cloud backend and a future Chrome extension are additions, not rewrites.

## 1. Design Constraint

The PRD's v1 is intentionally local-only (see PRD §3, Non-Goals) — no
backend, no accounts, everything on-device. But two things are already known
about the future:

1. **Cloud sync** — the data should eventually live somewhere durable and
   cross-device, not just in one iPhone's SwiftData store.
2. **A Chrome extension** — a second, different client needs to read and
   write the *same* data (e.g. quick-adding a Career Prep article while
   browsing on desktop).

A Chrome extension talking to data is the constraint that matters most here:
it rules out anything iOS-only (CloudKit's private database, for instance,
has no supported path for a non-Apple client). So even though v1 ships with
zero backend, the architecture below is written so that "add a backend" is a
matter of swapping one layer, not restructuring the app — and so that the
eventual backend is something a Chrome extension can also talk to directly.

## 2. Layered Architecture (v1 and beyond)

```
┌─────────────────────────────────────────────┐
│  SwiftUI Views (Home, Health, Social, ...)   │  Presentation
├─────────────────────────────────────────────┤
│  ViewModels (ObservableObject, per screen)   │  Presentation logic
├─────────────────────────────────────────────┤
│  Domain models (plain Swift structs)         │  Storage-agnostic
│  Medicine, WorkoutLog, Contact, Hobby,       │
│  PrepItem, TaskItem (Home's computed model)  │
├─────────────────────────────────────────────┤
│  Repository PROTOCOLS                        │  Contracts only
│  MedicineRepository, ContactRepository, ...  │
├───────────────┬───────────────────────────────┤
│  v1: SwiftData │  v2+: Remote-backed repo      │  Concrete implementations
│  implementation│  (Supabase) + local cache     │
└───────────────┴───────────────────────────────┘
```

**The rule that makes the future migration cheap:** Views and ViewModels only
ever talk to repository *protocols*, never to SwiftData or a network client
directly. `@Environment`/a small DI container decides at app-launch time
which concrete implementation gets wired in. Swapping local-only for
cloud-synced later means writing new implementations of the same protocols —
zero changes to any View or ViewModel.

```swift
protocol ContactRepository {
    func all() async throws -> [Contact]
    func upsert(_ contact: Contact) async throws
    func logContact(_ log: ContactLog) async throws
}

// v1
final class SwiftDataContactRepository: ContactRepository { ... }

// v2 (future, not built yet)
final class SupabaseContactRepository: ContactRepository { ... }
```

Each of the app's five domains (Health, Social, Hobbies, Career Prep, and the
computed Home aggregation) gets its own repository protocol — small and
focused rather than one giant `DataStore` — so each can evolve or migrate to
the cloud independently if needed.

### 2.1 Home is a view, not a data source
The Home tab has no repository of its own. It's a `HomeTaskAggregator` that
queries the four domain repositories and assembles `TaskItem` view models
(one Home design principle already established in the PRD: Home reflects
other tabs' data, it doesn't own any). This keeps a single source of truth
per fact — "was Iron taken today" lives in exactly one place — and means
Home automatically stays correct as the underlying repositories change
implementation.

## 3. Data Modeling — Sync-Ready From Day One

Even though v1 has no sync, every entity is modeled the way it would need to
be modeled *if* it synced, so the schema doesn't change shape later:

- **`id: UUID`** (client-generated, globally unique) on every entity —
  not an auto-incrementing local integer. This is what lets a record created
  offline on the phone merge cleanly with a server later, and it's also
  exactly what a Postgres `uuid primary key` expects.
- **`createdAt` / `updatedAt` timestamps** on every entity, updated on every
  local write. This is the minimum needed for last-write-wins conflict
  resolution once sync exists — retrofitting timestamps onto years of local
  data later is painful; having them from day one is free.
- **No entity references another by array/relationship magic that's
  SwiftData-specific** — relationships are modeled by foreign-key-style
  `UUID` fields (`contactId` on `ContactLog`, etc.), the same way they'd be
  modeled as foreign keys in Postgres. This keeps the local schema and the
  eventual server schema structurally identical, so the mapping code in a
  future `SupabaseXRepository` is closer to 1:1 than a translation layer.

## 4. The Cloud Backend (Future — Not Built in v1)

### 4.1 Recommendation: Supabase

| | Firebase | **Supabase (recommended)** | Custom backend |
|---|---|---|---|
| Data model | NoSQL documents | **Postgres (relational)** | Whatever you build |
| Fits this domain | Workable, but contacts/logs/streaks are naturally relational | **Natural fit** — foreign keys, joins for "streak from logs" | Natural fit, but you build it |
| iOS client | Firebase SDK | **`supabase-swift`** | You build/maintain it |
| Chrome extension client | Firebase JS SDK | **`supabase-js`** (same auth session pattern works in a browser extension) | You build/maintain it |
| Auth | Firebase Auth | **Supabase Auth** (email, Sign in with Apple, OAuth) | You build/maintain it |
| Per-user data isolation | Security Rules | **Postgres Row Level Security** — `user_id = auth.uid()` policies, enforced at the DB, not the client | You build/maintain it |
| Lock-in | Proprietary | **Open source, self-hostable later if ever wanted** | None, but most effort |
| Cost for a personal project | Free tier | **Free tier is generous enough for one user** | Hosting cost + your time |

Supabase wins here specifically *because* of the Chrome extension
requirement: it gives both clients (iOS via `supabase-swift`, Chrome
extension via `supabase-js`) a first-class SDK talking to the exact same
Postgres tables and the exact same auth session, with per-row security
enforced by the database itself rather than trusted to client code. A custom
backend would mean building and maintaining that twice (once conceptually
for each client) for no real benefit at this scale.

### 4.2 Schema sketch (mirrors the local models field-for-field)

```
medicines       (id, user_id, name, dosage, schedule_json, created_at, updated_at)
medicine_logs   (id, user_id, medicine_id, date, taken_at, created_at, updated_at)
workouts        (id, user_id, date, type, note, duration, created_at, updated_at)
contacts        (id, user_id, name, category, preferred_medium, cadence_days,
                 last_contacted_at, note, created_at, updated_at)
contact_logs    (id, user_id, contact_id, date, medium, note, created_at, updated_at)
hobbies         (id, user_id, name, status, commute_friendly, notes,
                 created_at, updated_at)
hobby_logs      (id, user_id, hobby_id, date, note, created_at, updated_at)
prep_items      (id, user_id, title, type, url, topic, status, added_at,
                 completed_at, created_at, updated_at)
```

Every table gets a Row Level Security policy of the same shape:
`user_id = auth.uid()`. Single-user today, but this means multi-user isolation
is correct from the first migration, not retrofitted.

### 4.3 Auth
Supabase Auth, most likely **Sign in with Apple** for the iOS app (native,
no password to manage) with the same Supabase project's OAuth flow reused
for the Chrome extension login. One account, one `user_id`, both clients.

## 5. Local ↔ Cloud Sync (Future)

When the backend is added, local SwiftData doesn't go away — it becomes an
**offline-first cache**, not the source of truth:

1. **Reads**: ViewModels keep reading from local SwiftData (instant, works
   offline). A background sync pulls remote changes into the local store.
2. **Writes**: A write still lands in SwiftData immediately (so the UI feels
   as fast as v1), and is also appended to a small **outbox** table of
   pending mutations. A `SyncEngine` drains the outbox to Supabase when
   online, and clears each entry once acknowledged.
3. **Conflicts**: resolved by `updated_at` — last write wins. This is a
   deliberate simplification appropriate for single-user personal data
   (the only "conflict" scenario is the same user editing on two devices
   close together, which is rare and low-stakes here); a more careful
   merge strategy is not worth the complexity at this scale.

This is the same repository-swap described in §2: `SwiftDataXRepository`
gets replaced by a `SupabaseXRepository` that wraps both the local cache and
the outbox/sync logic internally — the protocol, and everything above it,
doesn't change.

## 6. Where the Chrome Extension Fits

Once §4–5 exist, the Chrome extension is simply **a third client of the same
Supabase project** — no new backend work required to support it. Likely v1
scope for the extension (not now, future):

- Sign in with the same account (Supabase Auth in the browser).
- Quick-add to Career Prep's `prep_items` queue directly from an article tab
  (the single highest-value use case — capturing something to read *while
  already reading it*, rather than remembering to add it later from the
  phone).
- Possibly a lightweight "what's next" popup for Home, read-only.

It talks to Supabase directly via `supabase-js` with the same RLS-protected
tables the iOS app uses — there's no separate API to design or maintain.

## 7. What Changes vs. What Doesn't, When Cloud Is Added

| Stays exactly the same | Changes |
|---|---|
| Every SwiftUI View | Repository *implementations* (Local → Local+Remote) |
| Every ViewModel | New: `SyncEngine`, `AuthService`, an outbox table |
| Domain models (`Contact`, `PrepItem`, ...) | New: Supabase project + schema (§4.2) |
| Repository *protocols* | New: Chrome extension (separate small codebase) |

## 8. Why Not Just Start With Supabase Now?

Worth stating explicitly: v1 stays local-only per the PRD, on purpose. Adding
a backend before the app itself is validated would mean paying for auth,
sync, and conflict-handling complexity before knowing whether the daily-use
pattern (checklist-driven, one-tap logging) actually sticks. The point of
this document is that *when* it's time, it's a bounded, well-scoped addition
— not a rewrite — because the seams (repository protocols, UUID ids,
timestamps, RLS-shaped schema) are already in place.
