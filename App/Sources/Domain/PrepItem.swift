import Foundation
import SwiftData

enum PrepItemType: String, Codable, CaseIterable, Identifiable {
    case article
    case podcast

    var id: String { rawValue }
    var displayName: String { self == .article ? "Article" : "Podcast" }
}

enum PrepItemStatus: String, Codable, CaseIterable, Identifiable {
    case queued
    case done

    var id: String { rawValue }
}

@Model
final class PrepItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var typeRaw: String
    var url: String?
    var topic: String
    var statusRaw: String
    var addedAt: Date
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        type: PrepItemType,
        url: String? = nil,
        topic: String,
        status: PrepItemStatus = .queued
    ) {
        self.id = id
        self.title = title
        self.typeRaw = type.rawValue
        self.url = url
        self.topic = topic
        self.statusRaw = status.rawValue
        self.addedAt = .now
        self.completedAt = nil
        self.createdAt = .now
        self.updatedAt = .now
    }

    var type: PrepItemType {
        get { PrepItemType(rawValue: typeRaw) ?? .article }
        set { typeRaw = newValue.rawValue }
    }

    var status: PrepItemStatus {
        get { PrepItemStatus(rawValue: statusRaw) ?? .queued }
        set { statusRaw = newValue.rawValue }
    }
}
