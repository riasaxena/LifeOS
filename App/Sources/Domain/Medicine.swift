import Foundation
import SwiftData

/// A recurring medicine to take. `scheduleDays` holds ISO weekday numbers
/// (1 = Monday ... 7 = Sunday); defaults to every day.
@Model
final class Medicine {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosage: String?
    var scheduleDaysRaw: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MedicineLog.medicine)
    var logs: [MedicineLog] = []

    init(id: UUID = UUID(), name: String, dosage: String? = nil, scheduleDays: [Int] = Array(1...7)) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.scheduleDaysRaw = scheduleDays.map(String.init).joined(separator: ",")
        self.createdAt = .now
        self.updatedAt = .now
    }

    var scheduleDays: [Int] {
        scheduleDaysRaw.split(separator: ",").compactMap { Int($0) }
    }
}

/// One instance of a medicine being (or not yet being) taken on a given day.
@Model
final class MedicineLog {
    @Attribute(.unique) var id: UUID
    /// Start-of-day date this log belongs to.
    var date: Date
    var takenAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var medicine: Medicine?

    init(id: UUID = UUID(), date: Date, takenAt: Date? = nil, medicine: Medicine? = nil) {
        self.id = id
        self.date = date
        self.takenAt = takenAt
        self.createdAt = .now
        self.updatedAt = .now
        self.medicine = medicine
    }

    var isTaken: Bool { takenAt != nil }
}
