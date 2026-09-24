import Foundation
import Observation

@Observable
@MainActor
final class CareerPrepViewModel {
    private let repo: PrepItemRepository

    var queue: [PrepItem] = []
    var recentlyCompleted: [PrepItem] = []

    var upNext: PrepItem? { queue.first }
    var restOfQueue: [PrepItem] { Array(queue.dropFirst()) }

    init(repo: PrepItemRepository) {
        self.repo = repo
    }

    func load() {
        do {
            queue = try repo.queue()
            recentlyCompleted = try repo.recentlyCompleted(limit: 3)
        } catch {
            print("CareerPrepViewModel.load failed: \(error)")
        }
    }

    func markDone(_ item: PrepItem) {
        do {
            try repo.markDone(item)
            load()
        } catch {
            print("markDone failed: \(error)")
        }
    }

    func addItem(title: String, type: PrepItemType, url: String?, topic: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let item = PrepItem(title: title, type: type, url: url?.isEmpty == true ? nil : url, topic: topic)
        do {
            try repo.addItem(item)
            load()
        } catch {
            print("addItem failed: \(error)")
        }
    }
}
