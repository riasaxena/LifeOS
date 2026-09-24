import Foundation
import SwiftData

enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case weightsArms
    case weightsLegs
    case weightsBackBiceps
    case hotYoga
    case walk
    case rest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weightsArms: return "Weights - Arms"
        case .weightsLegs: return "Weights - Legs"
        case .weightsBackBiceps: return "Weights - Back/Biceps"
        case .hotYoga: return "Hot Yoga"
        case .walk: return "Walk"
        case .rest: return "Rest day"
        }
    }

    var emoji: String {
        switch self {
        case .weightsArms, .weightsLegs, .weightsBackBiceps: return "\u{1F3CB}\u{FE0F}"
        case .hotYoga: return "\u{1F9D8}"
        case .walk: return "\u{1F6B6}"
        case .rest: return "\u{1F634}"
        }
    }

    var countsForStreak: Bool { self != .rest }
}

@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    /// Start-of-day date this workout belongs to.
    var date: Date
    var typeRaw: String
    var note: String?
    var durationMinutes: Int?
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), date: Date, type: WorkoutType, note: String? = nil, durationMinutes: Int? = nil) {
        self.id = id
        self.date = date
        self.typeRaw = type.rawValue
        self.note = note
        self.durationMinutes = durationMinutes
        self.createdAt = .now
        self.updatedAt = .now
    }

    var type: WorkoutType {
        get { WorkoutType(rawValue: typeRaw) ?? .rest }
        set { typeRaw = newValue.rawValue }
    }
}
