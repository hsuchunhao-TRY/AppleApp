import Foundation
import SwiftData

// MARK: - Cube Model
@Model
final class Cube {
    @Attribute(.unique) var id: UUID
    @Attribute var title: String
    @Attribute var icon: String
    @Attribute var backgroundColor: String
    @Attribute var notes: String?
    @Attribute var tags: [String]
    @Attribute var actionType: String
    @Attribute var actionParameters: Data?
    @Attribute var createdAt: Date
    @Attribute var updatedAt: Date

    // Parent / Child Linking
    @Attribute var parentId: UUID?
    @Attribute var childrenData: Data?

    // Computed Children IDs
    var childrenIDs: [UUID] {
        get {
            guard let data = childrenData,
                  let ids = try? JSONDecoder().decode([UUID].self, from: data)
            else { return [] }
            return ids
        }
        set {
            childrenData = try? JSONEncoder().encode(newValue)
        }
    }

    // Convert raw string to enum
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    // Parameter decode/encode
    var parameters: [String: CodableValue]? {
        get {
            guard let data = actionParameters else { return nil }
            return try? JSONDecoder().decode([String: CodableValue].self, from: data)
        }
        set {
            actionParameters = newValue.flatMap { try? JSONEncoder().encode($0) }
            updatedAt = Date()
        }
    }

    // Initializer
    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: CubeActionType = .none,
        tags: [String] = [],
        actionParameters: [String: CodableValue]? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.tags = tags
        self.actionType = actionType.rawValue

        if let params = actionParameters {
            self.actionParameters = try? JSONEncoder().encode(params)
        }

        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    // Copy (clone new Cube)
    func copyItem(preserveParameters: Bool = true) -> Cube {
        Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            notes: notes,
            actionType: type,
            tags: tags,
            actionParameters: preserveParameters ? parameters : nil
        )
    }

    // Convert Cube → Template
    func toTemplate() -> CubeTemplate {
        CubeTemplate(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            tags: tags,
            notes: notes,
            actionType: type,
            defaultParameters: parameters
        )
    }
}

// MARK: - Children Handling
extension Cube {
    func appendChild(_ child: Cube) {
        var ids = childrenIDs
        ids.append(child.id)
        childrenIDs = ids
        child.parentId = self.id
    }
}
