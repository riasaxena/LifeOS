import Foundation
import SwiftData

@MainActor
protocol PrepItemRepository {
    func queue() throws -> [PrepItem]
    func recentlyCompleted(limit: Int) throws -> [PrepItem]
    func addItem(_ item: PrepItem) throws
    func markDone(_ item: PrepItem) throws
}

@MainActor
final class SwiftDataPrepItemRepository: PrepItemRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func queue() throws -> [PrepItem] {
        let queuedRaw = PrepItemStatus.queued.rawValue
        let descriptor = FetchDescriptor<PrepItem>(
            predicate: #Predicate { $0.statusRaw == queuedRaw },
            sortBy: [SortDescriptor(\.addedAt)]
        )
        return try context.fetch(descriptor)
    }

    func recentlyCompleted(limit: Int) throws -> [PrepItem] {
        let doneRaw = PrepItemStatus.done.rawValue
        var descriptor = FetchDescriptor<PrepItem>(
            predicate: #Predicate { $0.statusRaw == doneRaw },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func addItem(_ item: PrepItem) throws {
        context.insert(item)
        try context.save()
    }

    func markDone(_ item: PrepItem) throws {
        item.status = .done
        item.completedAt = .now
        item.updatedAt = .now
        try context.save()
    }
}
