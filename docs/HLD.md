# LifeOS — High-Level Design (HLD)

**Status:** Draft v1
**Companion to:** [`SYSTEM_DESIGN.md`](SYSTEM_DESIGN.md) (the written
rationale) — this document is the diagram set. Source `.puml` files live in
[`docs/diagrams/`](diagrams) so they can be edited and re-rendered
independently of this write-up.

## How to render these

The diagrams are plain [PlantUML](https://plantuml.com) — no build step is
required to read the source, but to view them as pictures, any of these
work:

- **VS Code**: install the "PlantUML" extension (jebbs.plantuml), open any
  `.puml` file, `Alt+D` to preview.
- **Online, no install**: paste a `.puml` file's contents into
  [plantuml.com/plantuml](https://www.plantuml.com/plantuml/uml/).
- **CLI** (if you want PNGs committed to the repo later): `brew install
  plantuml` then `plantuml docs/diagrams/*.puml` generates `.png` next to
  each source file.
- **IntelliJ / Xcode**: JetBrains has a PlantUML plugin; there's no native
  Xcode preview, VS Code or the web viewer are the easiest path.

Note: GitHub does **not** render ` ```plantuml ` code fences as images on its
own (it only auto-renders Mermaid) — the blocks below are the readable
source, not a live diagram. If you want diagrams that render automatically
on GitHub, the follow-up would be a small GitHub Action
(e.g. `plantuml-action`) that converts `docs/diagrams/*.puml` to `.svg` on
push and commits them — flagged as a nice-to-have, not done yet.

---

## 1. Component Architecture

Shows the layering from `SYSTEM_DESIGN.md` §2 as a diagram: shaded boxes are
**future** (cloud backend, Chrome extension), everything else is **built in
v1**. The key thing this diagram is meant to make visually obvious: nothing
above the "Data Layer" packages needs to change when the shaded boxes get
built.

Source: [`docs/diagrams/component-architecture.puml`](diagrams/component-architecture.puml)

```plantuml
@startuml component-architecture
title LifeOS - Component Architecture (v1 local + future cloud)

skinparam componentStyle rectangle
skinparam linetype ortho

package "iOS App" as IOSApp {

  package "Presentation" as Presentation {
    [SwiftUI Views] as Views
    [ViewModels] as VMs
  }

  package "Domain" as Domain {
    [Domain Models] as DomainModels
  }

  package "Repository Protocols" as Protocols {
    interface MedicineRepository
    interface ContactRepository
    interface HobbyRepository
    interface PrepItemRepository
  }

  package "Data Layer v1 (built now)" as DataV1 {
    [SwiftDataMedicineRepository] as SDMed
    [SwiftDataContactRepository] as SDContact
    [SwiftDataHobbyRepository] as SDHobby
    [SwiftDataPrepItemRepository] as SDPrep
    database "SwiftData" as SwiftDataDB
  }

  package "Data Layer - future" as DataFuture #F5F5F5 {
    [SupabaseContactRepository] as SBContact
    [SyncEngine] as Sync
    [Outbox] as Outbox
  }

}

package "Chrome Extension - future" as ChromeExt #F5F5F5 {
  [Popup UI] as ExtUI
  [supabase-js client] as ExtClient
}

cloud "Supabase - future" as Supabase #F5F5F5 {
  [Postgres + Row Level Security] as Postgres
  [Supabase Auth] as Auth
}

Views --> VMs
VMs --> DomainModels
VMs --> MedicineRepository
VMs --> ContactRepository
VMs --> HobbyRepository
VMs --> PrepItemRepository

MedicineRepository <|.. SDMed
ContactRepository <|.. SDContact
HobbyRepository <|.. SDHobby
PrepItemRepository <|.. SDPrep

SDMed --> SwiftDataDB
SDContact --> SwiftDataDB
SDHobby --> SwiftDataDB
SDPrep --> SwiftDataDB

ContactRepository <|.. SBContact
SBContact --> SwiftDataDB : reads
SBContact --> Outbox : writes
Outbox --> Sync
Sync --> Postgres : push / pull

ExtUI --> ExtClient
ExtClient --> Postgres
ExtClient --> Auth

Auth --> Postgres

note right of DataFuture
  Nothing above this layer changes
  when this is added. Views, VMs,
  domain models and the repository
  protocols stay exactly as they are.
end note

note right of ChromeExt
  Talks to the same Postgres tables
  and the same auth session as the
  iOS app. No separate API needed.
end note

@enduml
```

---

## 2. Data Model (ERD)

The entity shapes from `SYSTEM_DESIGN.md` §3 and §4.2 — modeled the same way
whether they're SwiftData objects today or Postgres tables later, so this one
diagram describes both.

Source: [`docs/diagrams/data-model-erd.puml`](diagrams/data-model-erd.puml)

```plantuml
@startuml data-model-erd
title LifeOS - Data Model (mirrors local SwiftData now and Postgres schema later)

hide circle
skinparam linetype ortho

entity Medicine {
  * id : UUID <<PK>>
  --
  name : String
  dosage : String
  schedule_json : String
  created_at : Date
  updated_at : Date
}

entity MedicineLog {
  * id : UUID <<PK>>
  --
  medicine_id : UUID <<FK>>
  date : Date
  taken_at : Date
  created_at : Date
  updated_at : Date
}

entity Workout {
  * id : UUID <<PK>>
  --
  date : Date
  type : WorkoutType
  note : String
  duration : Int
  created_at : Date
  updated_at : Date
}

entity Contact {
  * id : UUID <<PK>>
  --
  name : String
  category : Category
  preferred_medium : Medium
  cadence_days : Int
  last_contacted_at : Date
  note : String
  created_at : Date
  updated_at : Date
}

entity ContactLog {
  * id : UUID <<PK>>
  --
  contact_id : UUID <<FK>>
  date : Date
  medium : Medium
  note : String
  created_at : Date
  updated_at : Date
}

entity Hobby {
  * id : UUID <<PK>>
  --
  name : String
  status : HobbyStatus
  commute_friendly : Bool
  notes : String
  created_at : Date
  updated_at : Date
}

entity HobbyLog {
  * id : UUID <<PK>>
  --
  hobby_id : UUID <<FK>>
  date : Date
  note : String
  created_at : Date
  updated_at : Date
}

entity PrepItem {
  * id : UUID <<PK>>
  --
  title : String
  type : PrepItemType
  url : String
  topic : String
  status : PrepItemStatus
  added_at : Date
  completed_at : Date
  created_at : Date
  updated_at : Date
}

Medicine ||--o{ MedicineLog
Contact ||--o{ ContactLog
Hobby ||--o{ HobbyLog

note bottom of PrepItem
  The Home tab has no table of its own.
  Its Today checklist (TaskItem) is
  computed at read time from Medicine(Log),
  Contact(Log), Hobby(Log) and PrepItem -
  never stored separately.
end note

note as EnumsNote
  Category = friend | networking
  Medium = call | email
  HobbyStatus = active | wantToTry
  PrepItemType = article | podcast
  PrepItemStatus = queued | done

  Every table also gets a user_id UUID
  and a Row Level Security policy when
  the cloud backend is added
  (see SYSTEM_DESIGN.md section 4.2).
end note

@enduml
```

---

## 3. Sync Sequence (Future)

Walks through a single write (logging a call) end-to-end once the cloud
backend exists: local-first (instant UI update), queued in an outbox, then
reconciled with Supabase when online. **Not built in v1** — this is the
target behavior for when `SYSTEM_DESIGN.md` §5 gets implemented.

Source: [`docs/diagrams/sync-sequence.puml`](diagrams/sync-sequence.puml)

```plantuml
@startuml sync-sequence
title LifeOS - Local Write and Cloud Sync (future v2 flow, not built in v1)

actor Ria
participant "SwiftUI View" as View
participant "ViewModel" as VM
participant "SupabaseContactRepository" as Repo
database "SwiftData\n(local cache)" as Local
participant "Outbox" as Outbox
participant "SyncEngine" as Sync
cloud "Supabase\n(Postgres + RLS)" as Cloud

Ria -> View : Tap "Log a call"
View -> VM : logContact(contact)
VM -> Repo : logContact(contact)
Repo -> Local : write ContactLog (instant)
Repo -> Outbox : enqueue pending mutation
Repo --> VM : return immediately
VM --> View : UI updates (optimistic,\nfeels as fast as v1)

== later, when online ==

Sync -> Outbox : drain pending mutations
Sync -> Cloud : push ContactLog (upsert)
Cloud --> Sync : ack
Sync -> Outbox : clear entry

Sync -> Cloud : pull changes\nsince last_synced_at
Cloud --> Sync : rows changed by\nother devices/clients
Sync -> Local : merge\n(last-write-wins on updated_at)
Local --> VM : UI reflects\nremote changes

note over Sync, Cloud
  Conflict policy is deliberately simple:
  updated_at last-write-wins. Appropriate
  for single-user personal data - see
  SYSTEM_DESIGN.md section 5.
end note

@enduml
```

---

## 4. Deployment (Future)

Where each piece physically runs once cloud sync and the Chrome extension
exist. In v1, only "Ria's iPhone" is populated — everything else on this
diagram is future scope, shown shaded.

Source: [`docs/diagrams/deployment.puml`](diagrams/deployment.puml)

```plantuml
@startuml deployment
title LifeOS - Deployment (future state, cloud + extension added)

node "Ria's iPhone" as IPhone {
  [LifeOS iOS App] as IOSApp
  database "SwiftData (local cache)" as SD
}

node "Ria's Chrome Browser" as ChromeBrowser #F5F5F5 {
  [LifeOS Chrome Extension] as Ext
}

cloud "Supabase Cloud" as SupabaseCloud #F5F5F5 {
  [Postgres DB] as PG
  [Supabase Auth] as Auth
}

IOSApp --> SD : reads / writes (always)
IOSApp ..> PG : sync over HTTPS (future)
IOSApp ..> Auth : sign in (future)

Ext ..> PG : REST + Realtime (future)
Ext ..> Auth : OAuth session (future)

note bottom of SD
  v1 ships with ONLY this node
  populated. Everything else on
  this diagram is future scope.
end note

@enduml
```

---

## Change Log

| Date | Change |
|---|---|
| 2026-09-21 | Initial HLD: component architecture, data model ERD, sync sequence, deployment — all PlantUML, all diagram source under `docs/diagrams/` |
| 2026-09-21 | Fixed a syntax error (a `note` referencing a package by its quoted display name instead of an alias) and switched all diagrams to plain ASCII text and explicit aliases throughout, for reliable parsing in any PlantUML renderer |
