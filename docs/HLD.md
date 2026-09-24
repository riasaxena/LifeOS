# LifeOS — High-Level Design (HLD)

Short summary of the architecture. For the full reasoning (why Supabase,
sync strategy, trade-offs), see [`SYSTEM_DESIGN.md`](SYSTEM_DESIGN.md).

## Layers

```
SwiftUI Views
    -> ViewModels
        -> Domain models (Medicine, Contact, Hobby, PrepItem, ...)
        -> Repository protocols (MedicineRepository, ContactRepository, ...)
            -> v1:      SwiftData implementation (local only)
            -> future:  Supabase implementation (cloud sync + outbox)
```

Views and ViewModels only ever talk to repository *protocols*. Swapping
local-only for cloud-synced later is a new implementation of the same
protocols — no UI changes.

Home has no repository of its own — it's a computed view over the other
four tabs' data (Health, Social, Hobbies, Career Prep).

## Data

One entity per domain concept (`Medicine`, `MedicineLog`, `Workout`,
`Contact`, `ContactLog`, `Hobby`, `HobbyLog`, `PrepItem`), each with:

- a client-generated `UUID` id
- `created_at` / `updated_at` timestamps

— modeled that way from v1 even though nothing syncs yet, so the shape
doesn't change when the backend arrives.

## Future: Cloud + Chrome Extension

- **Backend:** Supabase (Postgres + Auth + Row Level Security). Chosen over
  Firebase/custom mainly because it gives both the iOS app
  (`supabase-swift`) and a future Chrome extension (`supabase-js`) the same
  tables and auth session, with per-user isolation enforced by the database.
- **Sync:** SwiftData becomes an offline cache; writes also queue in a
  local outbox; a `SyncEngine` pushes/pulls against Supabase with
  last-write-wins conflict resolution (`updated_at`) — simple, appropriate
  for single-user data.
- **Chrome extension:** just another client of the same Supabase project —
  no separate API to build.

## Not in v1

No backend, no accounts, no sync — this whole section is scoped for later.
