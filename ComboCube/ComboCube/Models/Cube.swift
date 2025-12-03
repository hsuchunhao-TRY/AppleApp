import Foundation
import SwiftData

// MARK: - Cube Action Type (UI / runtime enum)
enum CubeActionType: String {
    case combo
    case timer
    case countdown
    case repetitions
    case none

    init(raw: String) {
        self = CubeActionType(rawValue: raw) ?? .none
    }
}

// MARK: - Cube Model (SwiftData)
@Model
final class Cube {
    @Attribute(.unique) var id: UUID
    @Attribute var title: String
    @Attribute var icon: String
    @Attribute var backgroundColor: String
    @Attribute var notes: String?

    // Timer / Countdown 支援參數
    var duration: Double = 0               // 0 表示永遠計數
    var durationEn: Bool = true            // 是否啟用計時
    var durationProgressEn: Bool = true    // 是否顯示計時進度

    var tapCount: Int = 0                  // 觸碰計數
    var tapCountEn: Bool = false           // 是否啟用觸碰計數
    var tapCountProgressEn: Bool = false   // 是否顯示觸碰計數進度

    var loopCount: Int? = nil              // combo 專用循環次數
    var autoNextTask: Bool = false         // combo 切換下一個task

    @Attribute var actionType: String      // 存 enum rawValue
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    @Relationship(deleteRule: .nullify)
    var children: [Cube] = []

    @Attribute var tags: [String]
    @Attribute var sourceURL: URL?

    // Sound support
    var soundEn: Bool = false
    var soundURL: URL? = nil

    // MARK: - Initializer
    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: CubeActionType = .none,
        duration: Double? = nil,
        tapCount: Int? = nil,
        loopCount: Int? = nil,
        children: [Cube] = [],
        tags: [String] = [],
        sourceURL: URL? = nil,
        soundEn: Bool = false,
        soundURL: URL? = nil,
        autoNextTask: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.actionType = actionType.rawValue
        self.duration = duration ?? 0
        self.tapCount = tapCount ?? 0
        self.loopCount = loopCount
        self.children = children
        self.tags = tags
        self.sourceURL = sourceURL
        self.soundEn = soundEn
        self.soundURL = soundURL
        self.autoNextTask = autoNextTask
    }
}

// MARK: - Helpers / Runner Integration
extension Cube {

    /// 複製 Cube（淺拷貝，children 不會複製）
    func copy() -> Cube {
        Cube(
            title: self.title,
            icon: self.icon,
            backgroundColor: self.backgroundColor,
            notes: self.notes,
            actionType: self.type,
            duration: self.duration,
            tapCount: self.tapCount,
            loopCount: self.loopCount,
            children: [],
            tags: self.tags,
            sourceURL: self.sourceURL,
            soundEn: self.soundEn,
            soundURL: self.soundURL,
            autoNextTask: self.autoNextTask
        )
    }

    /// 加 child（必要時先 insert 到 context）
    func addChild(_ child: Cube, in context: ModelContext? = nil) {
        if let ctx = context {
            let childId = child.id
            let fetch: [Cube]
            do {
                fetch = try ctx.fetch(FetchDescriptor<Cube>(
                    predicate: #Predicate { $0.id == childId }
                ))
            } catch {
                print("Fetch failed: \(error)")
                return
            }

            if fetch.isEmpty {
                ctx.insert(child)
            }
        }
        children.append(child)
    }

    /// 生成對應 Task（Runner 會用）
    func toTask(runner: CubeRunner) -> CubeTask {
        switch type {
        case .combo:
            return ComboTask(cube: self, runner: runner)
        case .timer:
            return TimerTask(cube: self, runner: runner)
        case .countdown:
            return CountdownTask(cube: self, runner: runner)
        case .repetitions:
            return RepetitionTask(cube: self, runner: runner)
        case .none:
            return DummyTask(cube: self, runner: runner)
        @unknown default:
            return DummyTask(cube: self, runner: runner)
        }
    }

    /// 取得 children list
    func childrenList() -> [Cube] {
        children
    }
}