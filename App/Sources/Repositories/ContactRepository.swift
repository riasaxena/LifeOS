import Foundation
import SwiftData

@MainActor
protocol ContactRepository {
    func allContacts(category: ContactCategory) throws -> [Contact]
    func addContact(_ contact: Contact) throws
    func logContact(_ contact: Contact, medium: ContactMedium, note: String?) throws
}

@MainActor
final class SwiftDataContactRepository: ContactRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allContacts(category: ContactCategory) throws -> [Contact] {
        let raw = category.rawValue
        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate { $0.categoryRaw == raw }
        )
        let contacts = try context.fetch(descriptor)
        // Most overdue first.
        return contacts.sorted { a, b in
            (a.daysSinceContact ?? .max) - a.cadenceDays > (b.daysSinceContact ?? .max) - b.cadenceDays
        }
    }

    func addContact(_ contact: Contact) throws {
        context.insert(contact)
        try context.save()
    }

    func logContact(_ contact: Contact, medium: ContactMedium, note: String?) throws {
        let log = ContactLog(medium: medium, note: note, contact: contact)
        context.insert(log)
        contact.lastContactedAt = .now
        contact.updatedAt = .now
        try context.save()
    }
}
