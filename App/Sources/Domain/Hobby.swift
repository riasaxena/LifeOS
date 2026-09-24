import Foundation
import SwiftData

enum HobbyStatus: String, Codable, CaseIterable, Identifiable {
    case active
    case wantToTry

    var id: String { rawValue }
    var displayName: String { self == .active ? "Active" : "Want to try" }
}

@Model
final class Hobby {
    @Attribute(.unique) var id: UUID
    var name: String
    var statusRaw: String
    var commuteFriendly: Bool
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \HobbyLog.hobby)
    var logs: [HobbyLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        status: HobbyStatus,
        commuteFriendly: Bool,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.statusRaw = status.rawValue
        self.commuteFriendly = commuteFriendly
        self.notes = notes
        self.createdAt = .now
        self.updatedAt = .now
    }

    var status: HobbyStatus {
        get { HobbyStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var lastLoggedAt: Date? {
        logs.map(\.date).max()
    }
}

@Model
final class HobbyLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    var hobby: Hobby?

    init(id: UUID = UUID(), date: Date = .now, note: String? = nil, hobby: Hobby? = nil) {
        self.id = id
        self.date = date
        self.note = note
        self.createdAt = .now
        self.updatedAt = .now
        self.hobby = hobby
    }
}
