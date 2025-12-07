import Foundation
import SwiftData

// MARK: - Cube Action Type
enum CubeActionType: String, Codable {
    case combo
    case timer
    case countdown
    case repetitions
    case dice       // 骰子類型
    case none

    init(raw: String) {
        self = CubeActionType(rawValue: raw) ?? .none
    }
}

// MARK: - CodableValue 封裝任意可編碼型別
enum CodableValue: Codable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)

    init(_ value: any Codable) {
        switch value {
        case let v as Int: self = .int(v)
        case let v as Double: self = .double(v)
        case let v as Bool: self = .bool(v)
        case let v as String: self = .string(v)
        default: self = .string("\(value)")
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Int.self) { self = .int(v) }
        else if let v = try? container.decode(Double.self) { self = .double(v) }
        else if let v = try? container.decode(Bool.self) { self = .bool(v) }
        else { self = .string(try container.decode(String.self)) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .string(let v): try container.encode(v)
        }
    }

    var value: any Codable {
        switch self {
        case .int(let v): return v
        case .double(let v): return v
        case .bool(let v): return v
        case .string(let v): return v
        }
    }
}

// MARK: - Cube Model
@Model
final class Cube {
    @Attribute(.unique) var id: UUID
    @Attribute var title: String
    @Attribute var icon: String
    @Attribute var backgroundColor: String
    @Attribute var notes: String?
    @Attribute var tags: [String]
    @Attribute var sourceURL: URL?
    @Attribute var actionType: String        // 存 CubeActionType rawValue
    @Attribute var createdAt: Date
    @Attribute var updatedAt: Date

    // Relationships
    @Relationship(deleteRule: .nullify)
    var actions: [CubeAction] = []

    @Relationship(deleteRule: .nullify)
    var children: [Cube] = []

    // 方便存取 enum
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    // MARK: - Initializer
    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: CubeActionType = .none,
        tags: [String] = [],
        sourceURL: URL? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.tags = tags
        self.sourceURL = sourceURL
        self.actionType = actionType.rawValue
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    // MARK: - Helpers
    func copyItem() -> Cube {
        Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            notes: notes,
            actionType: type,
            tags: tags,
            sourceURL: sourceURL
        )
    }

    func addAction(_ action: CubeAction) {
        actions.append(action)
        updatedAt = Date()
    }
}

// MARK: - CubeAction Model
@Model
final class CubeAction {
    @Attribute(.unique) var id: UUID
    @Attribute var actionType: String
    @Attribute var parametersData: Data?    // JSON 存動態參數
    @Attribute var createdAt: Date
    @Attribute var updatedAt: Date

    // 關聯 Cube
    @Relationship(deleteRule: .nullify, inverse: \Cube.actions)
    var cube: Cube?

    // 方便存取 enum
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    // MARK: - Initializer
    init(type: CubeActionType, parameters: [String: CodableValue]? = nil) {
        self.id = UUID()
        self.actionType = type.rawValue
        let now = Date()
        self.createdAt = now
        self.updatedAt = now

        if let params = parameters {
            self.parametersData = try? JSONEncoder().encode(params)
        }
    }

    var parameters: [String: CodableValue]? {
        get { parametersData.flatMap { try? JSONDecoder().decode([String: CodableValue].self, from: $0) } }
        set {
            parametersData = newValue.flatMap { try? JSONEncoder().encode($0) }
            updatedAt = Date()
        }
    }

    // MARK: - Dice Feature
    func nextActionForDice(possibleActions: [CubeActionType]) -> CubeActionType {
        guard type == .dice else { return type }
        return possibleActions.randomElement() ?? .none
    }
}
