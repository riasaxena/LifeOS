import Foundation
import Observation

@Observable
@MainActor
final class HealthViewModel {
    private let medicineRepo: MedicineRepository
    private let workoutRepo: WorkoutRepository

    var medicines: [Medicine] = []
    var todaysLogs: [MedicineLog] = []
    var todaysWorkout: Workout?
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var last30DayAdherence: Double = 0
    var last4Weeks: [[Bool]] = [] // 4 rows of 7 days, oldest-first within a row

    init(medicineRepo: MedicineRepository, workoutRepo: WorkoutRepository) {
        self.medicineRepo = medicineRepo
        self.workoutRepo = workoutRepo
    }

    func load() {
        do {
            medicines = try medicineRepo.allMedicines()
            todaysLogs = try medicineRepo.logsForToday()
            todaysWorkout = try workoutRepo.workout(on: .now)
            computeStreak()
        } catch {
            print("HealthViewModel.load failed: \(error)")
        }
    }

    func markTaken(_ medicine: Medicine) {
        do {
            try medicineRepo.markTaken(medicine, on: .now)
            load()
        } catch {
            print("markTaken failed: \(error)")
        }
    }

    /// Today's log for a medicine, if it's due today.
    func todaysLog(for medicine: Medicine) -> MedicineLog? {
        todaysLogs.first { $0.medicine?.id == medicine.id }
    }

    func addMedicine(name: String, dosage: String?, scheduleDays: [Int]) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, !scheduleDays.isEmpty else { return }
        let medicine = Medicine(name: name, dosage: dosage?.isEmpty == true ? nil : dosage, scheduleDays: scheduleDays)
        do {
            try medicineRepo.addMedicine(medicine)
            load()
        } catch {
            print("addMedicine failed: \(error)")
        }
    }

    func deleteMedicine(_ medicine: Medicine) {
        do {
            try medicineRepo.deleteMedicine(medicine)
            load()
        } catch {
            print("deleteMedicine failed: \(error)")
        }
    }

    /// Tapping today's already-selected workout clears it.
    func logWorkout(_ type: WorkoutType) {
        do {
            if todaysWorkout?.type == type {
                try workoutRepo.clearWorkout(on: .now)
            } else {
                try workoutRepo.logWorkout(type: type, on: .now, note: nil)
            }
            load()
        } catch {
            print("logWorkout failed: \(error)")
        }
    }

    private func computeStreak() {
        do {
            let adherence = try medicineRepo.adherenceHistory(days: 60)
            let workouts = try workoutRepo.workoutHistory(days: 60)

            // Combine by index (both are newest-first, same length window).
            let count = min(adherence.count, workouts.count)
            let combined: [Bool] = (0..<count).map { adherence[$0].allTaken && workouts[$0].worked }

            var current = 0
            for ok in combined {
                if ok { current += 1 } else { break }
            }
            currentStreak = current

            var longest = 0
            var running = 0
            for ok in combined {
                running = ok ? running + 1 : 0
                longest = max(longest, running)
            }
            longestStreak = longest

            let last30 = combined.prefix(30)
            last30DayAdherence = last30.isEmpty ? 0 : Double(last30.filter { $0 }.count) / Double(last30.count)

            let last28 = Array(combined.prefix(28).reversed()) // oldest-first
            last4Weeks = stride(from: 0, to: last28.count, by: 7).map { start in
                Array(last28[start..<min(start + 7, last28.count)])
            }
        } catch {
            print("computeStreak failed: \(error)")
        }
    }
}
