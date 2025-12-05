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

    // MARK: - Identity
    @Attribute(.unique) var id: UUID

    // MARK: - Cube Information (顯示用)
    @Attribute var title: String
    @Attribute var icon: String
    @Attribute var backgroundColor: String
    @Attribute var notes: String?

    // MARK: - Metadata & Sound (放在 ActionType 上面)
    @Attribute var tags: [String]
    @Attribute var sourceURL: URL?
    var soundEn: Bool = false
    var soundURL: URL? = nil

    // MARK: - Action Type
    @Attribute var actionType: String      // 存 enum rawValue
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    // MARK: - Timer / Countdown Settings
    var duration: Double = 0               // 0 表示永遠計數
    var durationEn: Bool = true
    var durationProgressEn: Bool = true

    // MARK: - Tap Count Settings
    var tapCount: Int = 0
    var tapCountEn: Bool = false
    var tapCountProgressEn: Bool = false

    // MARK: - Combo Control & Structure
    var loopCount: Int? = nil              // combo 專用循環次數
    var autoNextTask: Bool = false         // combo 是否自動切下一 task
    @Relationship(deleteRule: .nullify)
    var children: [Cube] = []

    // MARK: - Initializer
    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,

        actionType: CubeActionType = .none,

        // Timer
        duration: Double? = nil,
        durationEn: Bool = true,
        durationProgressEn: Bool = true,

        // Tap
        tapCount: Int? = nil,
        tapCountEn: Bool = false,
        tapCountProgressEn: Bool = false,

        // Combo
        loopCount: Int? = nil,
        autoNextTask: Bool = false,
        children: [Cube] = [],

        // Metadata & Sound
        tags: [String] = [],
        sourceURL: URL? = nil,
        soundEn: Bool = false,
        soundURL: URL? = nil
    ) {
        self.id = UUID()

        // Info
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes

        // Meta & Sound
        self.tags = tags
        self.sourceURL = sourceURL
        self.soundEn = soundEn
        self.soundURL = soundURL

        // Action
        self.actionType = actionType.rawValue

        // Timer
        self.duration = duration ?? 0
        self.durationEn = durationEn
        self.durationProgressEn = durationProgressEn

        // Tap
        self.tapCount = tapCount ?? 0
        self.tapCountEn = tapCountEn
        self.tapCountProgressEn = tapCountProgressEn

        // Combo
        self.loopCount = loopCount
        self.autoNextTask = autoNextTask
        self.children = children
    }
}

// MARK: - Helpers / Runner Integration
extension Cube {

    /// 複製 Cube（純資料複製，children 不處理）
    func copyItem() -> Cube {
        Cube(
            title: self.title,
            icon: self.icon,
            backgroundColor: self.backgroundColor,
            notes: self.notes,
            actionType: self.type,

            // Timer / Countdown
            duration: self.duration,
            durationEn: self.durationEn,
            durationProgressEn: self.durationProgressEn,

            // Tap
            tapCount: self.tapCount,
            tapCountEn: self.tapCountEn,
            tapCountProgressEn: self.tapCountProgressEn,

            // Combo
            loopCount: self.loopCount,
            autoNextTask: self.autoNextTask,

            // Children
            children: [],

            // Metadata & Sound
            tags: self.tags,
            sourceURL: self.sourceURL,
            soundEn: self.soundEn,
            soundURL: self.soundURL
        )
    }

    /// 生成對應 Task（Runner 使用）
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

    /// 只讀 children
    func childrenList() -> [Cube] {
        children
    }
}
