import Foundation
import SwiftData

@MainActor
protocol WorkoutRepository {
    func workout(on date: Date) throws -> Workout?
    func logWorkout(type: WorkoutType, on date: Date, note: String?) throws
    /// Most recent `days` days, newest first, true if a non-rest workout was logged.
    func workoutHistory(days: Int) throws -> [(date: Date, worked: Bool)]
}

@MainActor
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func workout(on date: Date) throws -> Workout? {
        let start = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.date == start })
        return try context.fetch(descriptor).first
    }

    func logWorkout(type: WorkoutType, on date: Date, note: String?) throws {
        let start = Calendar.current.startOfDay(for: date)
        if let existing = try workout(on: start) {
            existing.type = type
            existing.note = note
            existing.updatedAt = .now
        } else {
            context.insert(Workout(date: start, type: type, note: note))
        }
        try context.save()
    }

    func workoutHistory(days: Int) throws -> [(date: Date, worked: Bool)] {
        let calendar = Calendar.current
        var result: [(date: Date, worked: Bool)] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            let workout = try workout(on: day)
            result.append((calendar.startOfDay(for: day), workout?.type.countsForStreak == true))
        }
        return result
    }
}
