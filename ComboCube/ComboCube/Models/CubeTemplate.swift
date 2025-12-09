// MARK: - CubeTemplate
import Foundation

// MARK: - CubeActionType
enum CubeActionType: String, Codable {
    case combo, dice, timer, countdown, repetitions, none
    case unknown

    init(raw: String) {
        self = CubeActionType(rawValue: raw) ?? .none
    }
}

// MARK: - CodableValue
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

// MARK: - CubeTemplate
struct CubeTemplate: Codable {
    var title: String
    var icon: String
    var backgroundColor: String
    var tags: [String]
    var notes: String?
    var actionType: CubeActionType
    var defaultParameters: [String: CodableValue]?

    // MARK: - Custom Decoder (Fix self immutable problem)
    enum CodingKeys: String, CodingKey {
        case title, icon, backgroundColor, tags, notes, actionType, defaultParameters
    }

    init(
        title: String,
        icon: String,
        backgroundColor: String,
        tags: [String],
        notes: String? = nil,
        actionType: CubeActionType,
        defaultParameters: [String: CodableValue]? = nil
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.tags = tags
        self.notes = notes
        self.actionType = actionType
        self.defaultParameters = defaultParameters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decode(String.self, forKey: .title)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.actionType = try container.decode(CubeActionType.self, forKey: .actionType)
        self.defaultParameters = try container.decodeIfPresent([String: CodableValue].self, forKey: .defaultParameters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(actionType, forKey: .actionType)
        try container.encodeIfPresent(defaultParameters, forKey: .defaultParameters)
    }

    // MARK: - Type Safe Parameter API
    func duration(_ seconds: Double) -> CubeTemplate {
        addParameter("duration", value: .double(seconds))
    }

    func loopCount(_ count: Int) -> CubeTemplate {
        addParameter("loopCount", value: .int(count))
    }

    func autoNextTask(_ enabled: Bool) -> CubeTemplate {
        addParameter("autoNextTask", value: .bool(enabled))
    }

    func addParameter(_ key: String, value: CodableValue) -> CubeTemplate {
        var copy = self
        if copy.defaultParameters == nil { copy.defaultParameters = [:] }
        copy.defaultParameters?[key] = value
        return copy
    }

    // MARK: - Create Cube
    func makeCube(customParameters: [String: CodableValue]? = nil) -> Cube {
        var final = defaultParameters ?? [:]
        if let custom = customParameters {
            for (k, v) in custom { final[k] = v }
        }
        return Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            actionType: actionType,
            tags: tags,
            actionParameters: final
        )
    }
}

extension Data {
    func toString() -> String? {
        String(data: self, encoding: .utf8)
    }
}
