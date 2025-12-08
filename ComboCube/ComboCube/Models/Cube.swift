import Foundation
import SwiftData

// MARK: - Cube Action Type
enum CubeActionType: String, Codable {
    case combo
    case dice
    case timer
    case countdown
    case repetitions
    case none
    case unknown 

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
    @Attribute var videoURL: URL?
    @Attribute var actionType: String        // CubeActionType.rawValue
    @Attribute var actionParameters: Data?   // JSON 結構存動態資料
    @Attribute var createdAt: Date
    @Attribute var updatedAt: Date

    @Attribute var childrenData: Data?  // 儲存 [UUID]

    var childrenIDs: [UUID] {
        get {
            guard let data = childrenData,
                  let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
                return []
            }
            return ids
        }
        set {
            childrenData = try? JSONEncoder().encode(newValue)
        }
    }

    func appendChild(_ child: Cube) {
        var ids = childrenIDs
        ids.append(child.id)
        childrenIDs = ids
    }
    
    // MARK: - Enum Bridge
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
        videoURL: URL? = nil,
        actionParameters: [String: CodableValue]? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.tags = tags
        self.videoURL = videoURL
        self.actionType = actionType.rawValue

        if let params = actionParameters {
            self.actionParameters = try? JSONEncoder().encode(params)
        } else {
            self.actionParameters = nil
        }

        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    // MARK: - JSON Helper
    var parameters: [String: CodableValue]? {
        get {
            actionParameters.flatMap { try? JSONDecoder().decode([String: CodableValue].self, from: $0) }
        }
        set {
            actionParameters = newValue.flatMap { try? JSONEncoder().encode($0) }
            updatedAt = Date()
        }
    }

    // MARK: - Copy
    func copyItem(preserveParameters: Bool = true) -> Cube {
        Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            notes: notes,
            actionType: type,
            tags: tags,
            videoURL: videoURL,
            actionParameters: preserveParameters ? parameters : nil
        )
    }
}

// MARK: - Cube Factory Example
struct CubeFactory {
    static let warmupTemplate = CubeTemplate(
        title: "熱身 10 分鐘",
        icon: "🔥",
        backgroundColor: "#FFA500",
        tags: ["warmup", "easy"],
        actionType: .timer,
        defaultParameters: ["duration": .double(Double(10*60))],
    )

    static func makeWarmupCube() -> Cube {
        warmupTemplate.makeCube()
    }
}
