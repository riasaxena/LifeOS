import Foundation
import Observation

@Observable
@MainActor
final class SocialViewModel {
    private let repo: ContactRepository

    var selectedCategory: ContactCategory = .friend
    var friends: [Contact] = []
    var workContacts: [Contact] = []

    var visibleContacts: [Contact] {
        selectedCategory == .friend ? friends : workContacts
    }

    init(repo: ContactRepository) {
        self.repo = repo
    }

    func load() {
        do {
            friends = try repo.allContacts(category: .friend)
            workContacts = try repo.allContacts(category: .work)
        } catch {
            print("SocialViewModel.load failed: \(error)")
        }
    }

    func logCall(_ contact: Contact, medium: ContactMedium? = nil, note: String? = nil) {
        do {
            try repo.logContact(contact, medium: medium ?? contact.preferredMedium, note: note)
            load()
        } catch {
            print("logCall failed: \(error)")
        }
    }

    func addPerson(
        name: String,
        category: ContactCategory,
        preferredMedium: ContactMedium,
        cadenceDays: Int,
        note: String?
    ) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let contact = Contact(
            name: name,
            category: category,
            preferredMedium: preferredMedium,
            cadenceDays: cadenceDays,
            lastContactedAt: .now, // starts "just contacted" so it doesn't jump to the top
            note: note?.isEmpty == true ? nil : note
        )
        do {
            try repo.addContact(contact)
            load()
        } catch {
            print("addPerson failed: \(error)")
        }
    }
}
