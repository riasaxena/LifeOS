import Foundation
import SwiftData

enum ContactCategory: String, Codable, CaseIterable, Identifiable {
    case friend
    case work

    var id: String { rawValue }
    var displayName: String { self == .friend ? "Friend" : "Work contact" }
}

enum ContactMedium: String, Codable, CaseIterable, Identifiable {
    case call
    case email

    var id: String { rawValue }
    var displayName: String { self == .call ? "Call" : "Email" }
}

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var preferredMediumRaw: String
    var cadenceDays: Int
    var lastContactedAt: Date?
    var note: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ContactLog.contact)
    var logs: [ContactLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        category: ContactCategory,
        preferredMedium: ContactMedium,
        cadenceDays: Int,
        lastContactedAt: Date? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.preferredMediumRaw = preferredMedium.rawValue
        self.cadenceDays = cadenceDays
        self.lastContactedAt = lastContactedAt
        self.note = note
        self.createdAt = .now
        self.updatedAt = .now
    }

    var category: ContactCategory {
        get { ContactCategory(rawValue: categoryRaw) ?? .friend }
        set { categoryRaw = newValue.rawValue }
    }

    var preferredMedium: ContactMedium {
        get { ContactMedium(rawValue: preferredMediumRaw) ?? .call }
        set { preferredMediumRaw = newValue.rawValue }
    }

    /// Days since last contacted, or nil if never contacted.
    var daysSinceContact: Int? {
        guard let last = lastContactedAt else { return nil }
        return Calendar.current.dateComponents([.day], from: last, to: .now).day
    }

    var isOverdue: Bool {
        guard let days = daysSinceContact else { return true }
        return days >= cadenceDays
    }
}

@Model
final class ContactLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mediumRaw: String
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    var contact: Contact?

    init(id: UUID = UUID(), date: Date = .now, medium: ContactMedium, note: String? = nil, contact: Contact? = nil) {
        self.id = id
        self.date = date
        self.mediumRaw = medium.rawValue
        self.note = note
        self.createdAt = .now
        self.updatedAt = .now
        self.contact = contact
    }

    var medium: ContactMedium {
        get { ContactMedium(rawValue: mediumRaw) ?? .call }
        set { mediumRaw = newValue.rawValue }
    }
}
