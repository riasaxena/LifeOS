import Foundation
import SwiftData

@MainActor
protocol HobbyRepository {
    func allHobbies() throws -> [Hobby]
    func addHobby(_ hobby: Hobby) throws
    func logHobby(_ hobby: Hobby, note: String?) throws
    /// A commute-friendly hobby, preferring ones not logged recently.
    func tonightsSuggestion() throws -> Hobby?
}

@MainActor
final class SwiftDataHobbyRepository: HobbyRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allHobbies() throws -> [Hobby] {
        try context.fetch(FetchDescriptor<Hobby>(sortBy: [SortDescriptor(\.name)]))
    }

    func addHobby(_ hobby: Hobby) throws {
        context.insert(hobby)
        try context.save()
    }

    func logHobby(_ hobby: Hobby, note: String?) throws {
        context.insert(HobbyLog(note: note, hobby: hobby))
        hobby.updatedAt = .now
        try context.save()
    }

    func tonightsSuggestion() throws -> Hobby? {
        let candidates = try allHobbies().filter { $0.commuteFriendly }
        guard !candidates.isEmpty else { return nil }
        return candidates.min { a, b in
            (a.lastLoggedAt ?? .distantPast) < (b.lastLoggedAt ?? .distantPast)
        }
    }
}
