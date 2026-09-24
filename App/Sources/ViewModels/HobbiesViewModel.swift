import Foundation
import Observation

@Observable
@MainActor
final class HobbiesViewModel {
    private let repo: HobbyRepository

    var hobbies: [Hobby] = []
    var tonightsPick: Hobby?

    init(repo: HobbyRepository) {
        self.repo = repo
    }

    func load() {
        do {
            hobbies = try repo.allHobbies()
            tonightsPick = try repo.tonightsSuggestion()
        } catch {
            print("HobbiesViewModel.load failed: \(error)")
        }
    }

    func logToday(_ hobby: Hobby, note: String? = nil) {
        do {
            try repo.logHobby(hobby, note: note)
            load()
        } catch {
            print("logToday failed: \(error)")
        }
    }

    func addHobby(name: String, status: HobbyStatus, commuteFriendly: Bool, notes: String?) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let hobby = Hobby(name: name, status: status, commuteFriendly: commuteFriendly, notes: notes?.isEmpty == true ? nil : notes)
        do {
            try repo.addHobby(hobby)
            load()
        } catch {
            print("addHobby failed: \(error)")
        }
    }
}
