import SwiftData
import Foundation

@Model
class Cube {
    @Attribute(.unique) var id: UUID
    @Attribute var title: String
    @Attribute var icon: String
    @Attribute var backgroundColor: String
    @Attribute var notes: String?

    @Attribute var actionType: String
    @Attribute var duration: TimeInterval?
    @Attribute var repetitions: Int?

    // Combo children
    @Relationship(deleteRule: .nullify) var children: [Cube] = []

    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: String,
        duration: TimeInterval? = nil,
        repetitions: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.actionType = actionType
        self.duration = duration
        self.repetitions = repetitions
    }
}
