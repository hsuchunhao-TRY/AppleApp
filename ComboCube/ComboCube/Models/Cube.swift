import SwiftData
import Foundation

// MARK: - CubeActionType
enum CubeActionType: String {
    case combo
    case timer
    case countdown
    case repetitions
    case none

    init(from rawValue: String) {
        self = CubeActionType(rawValue: rawValue) ?? .none
    }
}

// MARK: - Cube Model
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

    // Swift 層用 enum
    var type: CubeActionType {
        get { CubeActionType(from: actionType) }
        set { actionType = newValue.rawValue }
    }
    
    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: CubeActionType,
        duration: TimeInterval? = nil,
        repetitions: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.actionType = actionType.rawValue
        self.duration = duration
        self.repetitions = repetitions
    }
}
