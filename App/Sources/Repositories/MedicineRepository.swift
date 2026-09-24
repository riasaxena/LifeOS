import Foundation
import SwiftData

/// Views and ViewModels only ever depend on this protocol, never on
/// SwiftData directly - see docs/HLD.md. A future SupabaseMedicineRepository
/// can implement this same protocol with no changes above this layer.
@MainActor
protocol MedicineRepository {
    func allMedicines() throws -> [Medicine]
    func addMedicine(_ medicine: Medicine) throws
    func logsForToday() throws -> [MedicineLog]
    func markTaken(_ medicine: Medicine, on date: Date) throws
    /// Days, most recent first, where every medicine due that day had a log
    /// with a non-nil takenAt. Used for the Health streak.
    func adherenceHistory(days: Int) throws -> [(date: Date, allTaken: Bool)]
}

@MainActor
final class SwiftDataMedicineRepository: MedicineRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allMedicines() throws -> [Medicine] {
        try context.fetch(FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\.name)]))
    }

    func addMedicine(_ medicine: Medicine) throws {
        context.insert(medicine)
        try context.save()
    }

    func logsForToday() throws -> [MedicineLog] {
        let start = Calendar.current.startOfDay(for: .now)
        let descriptor = FetchDescriptor<MedicineLog>(
            predicate: #Predicate { $0.date == start }
        )
        let existing = try context.fetch(descriptor)

        // Make sure every medicine scheduled today has a log row to show/tap.
        let medicines = try allMedicines()
        let weekday = Calendar.current.component(.weekday, from: .now)
        // Foundation's .weekday is 1 = Sunday...7 = Saturday; our schedule
        // uses ISO 1 = Monday...7 = Sunday, so remap.
        let isoWeekday = weekday == 1 ? 7 : weekday - 1

        var logsByMedicine = Dictionary(uniqueKeysWithValues: existing.compactMap { log in
            log.medicine.map { ($0.id, log) }
        })

        for medicine in medicines where medicine.scheduleDays.contains(isoWeekday) {
            if logsByMedicine[medicine.id] == nil {
                let log = MedicineLog(date: start, medicine: medicine)
                context.insert(log)
                logsByMedicine[medicine.id] = log
            }
        }
        try context.save()

        return try context.fetch(descriptor)
    }

    func markTaken(_ medicine: Medicine, on date: Date) throws {
        let start = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<MedicineLog>(
            predicate: #Predicate { $0.date == start }
        )
        let logs = try context.fetch(descriptor)
        if let log = logs.first(where: { $0.medicine?.id == medicine.id }) {
            log.takenAt = .now
            log.updatedAt = .now
        } else {
            let log = MedicineLog(date: start, takenAt: .now, medicine: medicine)
            context.insert(log)
        }
        try context.save()
    }

    func adherenceHistory(days: Int) throws -> [(date: Date, allTaken: Bool)] {
        let calendar = Calendar.current
        let medicines = try allMedicines()
        guard !medicines.isEmpty else { return [] }

        var result: [(date: Date, allTaken: Bool)] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let start = calendar.startOfDay(for: day)
            let isoWeekday = { () -> Int in
                let w = calendar.component(.weekday, from: day)
                return w == 1 ? 7 : w - 1
            }()
            let dueToday = medicines.filter { $0.scheduleDays.contains(isoWeekday) }
            guard !dueToday.isEmpty else {
                result.append((start, true))
                continue
            }
            let descriptor = FetchDescriptor<MedicineLog>(predicate: #Predicate { $0.date == start })
            let logs = try context.fetch(descriptor)
            let allTaken = dueToday.allSatisfy { medicine in
                logs.first(where: { $0.medicine?.id == medicine.id })?.isTaken == true
            }
            result.append((start, allTaken))
        }
        return result
    }
}
