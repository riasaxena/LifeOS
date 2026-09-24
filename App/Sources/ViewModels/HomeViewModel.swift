import Foundation
import Observation

enum TaskSection: String, CaseIterable {
    case morning = "Morning"
    case anytime = "Anytime"
    case evening = "This evening"
}

enum TaskAction {
    case takeMedicine(Medicine)
    case logWorkout
    case callContact(Contact)
    case doHobby(Hobby)
    case readPrepItem(PrepItem)
}

struct TaskItem: Identifiable {
    let id: String
    let section: TaskSection
    let title: String
    let subtitle: String
    let isDone: Bool
    let action: TaskAction?
}

/// Home has no data of its own - it's a computed view over the other four
/// tabs' repositories (see docs/HLD.md).
@Observable
@MainActor
final class HomeViewModel {
    private let medicineRepo: MedicineRepository
    private let workoutRepo: WorkoutRepository
    private let contactRepo: ContactRepository
    private let hobbyRepo: HobbyRepository
    private let prepItemRepo: PrepItemRepository

    var tasks: [TaskItem] = []
    var currentStreak: Int = 0

    var doneCount: Int { tasks.filter(\.isDone).count }
    var totalCount: Int { tasks.count }

    init(
        medicineRepo: MedicineRepository,
        workoutRepo: WorkoutRepository,
        contactRepo: ContactRepository,
        hobbyRepo: HobbyRepository,
        prepItemRepo: PrepItemRepository
    ) {
        self.medicineRepo = medicineRepo
        self.workoutRepo = workoutRepo
        self.contactRepo = contactRepo
        self.hobbyRepo = hobbyRepo
        self.prepItemRepo = prepItemRepo
    }

    func load() {
        var items: [TaskItem] = []

        do {
            // Health: medicines due today.
            let logs = try medicineRepo.logsForToday()
            for log in logs {
                guard let medicine = log.medicine else { continue }
                items.append(TaskItem(
                    id: "med-\(medicine.id)",
                    section: .morning,
                    title: medicine.name,
                    subtitle: log.isTaken ? "Health - taken" : "Health - not yet taken",
                    isDone: log.isTaken,
                    action: log.isTaken ? nil : .takeMedicine(medicine)
                ))
            }

            // Health: today's workout.
            let workout = try workoutRepo.workout(on: .now)
            items.append(TaskItem(
                id: "workout-today",
                section: .anytime,
                title: workout != nil ? "Workout logged - \(workout!.type.displayName)" : "Log today's workout",
                subtitle: "Health",
                isDone: workout != nil,
                action: workout != nil ? nil : .logWorkout
            ))

            // Social: most overdue contact across both lists.
            let friends = try contactRepo.allContacts(category: .friend)
            let work = try contactRepo.allContacts(category: .work)
            if let mostOverdue = (friends + work).filter(\.isOverdue).first {
                items.append(TaskItem(
                    id: "contact-\(mostOverdue.id)",
                    section: .anytime,
                    title: "Call \(mostOverdue.name)",
                    subtitle: "Social - overdue",
                    isDone: false,
                    action: .callContact(mostOverdue)
                ))
            }

            // Career Prep: next item in queue.
            let queue = try prepItemRepo.queue()
            if let next = queue.first {
                items.append(TaskItem(
                    id: "prep-\(next.id)",
                    section: .morning,
                    title: next.title,
                    subtitle: "Career Prep - \(next.type.displayName)",
                    isDone: false,
                    action: .readPrepItem(next)
                ))
            }

            // Hobbies: tonight's suggestion.
            if let hobby = try hobbyRepo.tonightsSuggestion() {
                let loggedToday = hobby.lastLoggedAt.map { Calendar.current.isDateInToday($0) } ?? false
                items.append(TaskItem(
                    id: "hobby-\(hobby.id)",
                    section: .evening,
                    title: loggedToday ? "\(hobby.name) - done today" : "\(hobby.name) on the commute home",
                    subtitle: "Hobbies",
                    isDone: loggedToday,
                    action: loggedToday ? nil : .doHobby(hobby)
                ))
            }

            tasks = items

            // Streak, mirrored from HealthViewModel's calculation.
            let adherence = try medicineRepo.adherenceHistory(days: 60)
            let workouts = try workoutRepo.workoutHistory(days: 60)
            let count = min(adherence.count, workouts.count)
            var streak = 0
            for i in 0..<count {
                if adherence[i].allTaken && workouts[i].worked { streak += 1 } else { break }
            }
            currentStreak = streak
        } catch {
            print("HomeViewModel.load failed: \(error)")
        }
    }

    func complete(_ item: TaskItem) {
        guard let action = item.action else { return }
        do {
            switch action {
            case .takeMedicine(let medicine):
                try medicineRepo.markTaken(medicine, on: .now)
            case .logWorkout:
                break // Deep-link to Health tab in a future pass; Home doesn't own workout type selection.
            case .callContact(let contact):
                try contactRepo.logContact(contact, medium: contact.preferredMedium, note: nil)
            case .doHobby(let hobby):
                try hobbyRepo.logHobby(hobby, note: nil)
            case .readPrepItem(let prepItem):
                try prepItemRepo.markDone(prepItem)
            }
            load()
        } catch {
            print("complete(_:) failed: \(error)")
        }
    }
}
