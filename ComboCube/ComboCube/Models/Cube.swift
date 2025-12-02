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

    // 基礎欄位（以 String 存 action 類型）
    @Attribute var actionType: String
    @Attribute var duration: TimeInterval?
    @Attribute var repetitions: Int?

    // Combo children（自關聯）
    @Relationship(deleteRule: .nullify)
    var children: [Cube] = []

    // Runtime enum
    var type: CubeActionType {
        get { CubeActionType(raw: actionType) }
        set { actionType = newValue.rawValue }
    }

    init(
        title: String,
        icon: String,
        backgroundColor: String,
        notes: String? = nil,
        actionType: CubeActionType = .none,
        duration: TimeInterval? = nil,
        repetitions: Int? = nil,
        children: [Cube] = []
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.notes = notes
        self.actionType = actionType.rawValue
        self.duration = duration
        self.repetitions = repetitions
        self.children = children
    }
}

// MARK: - Helpers / Integration with Runner
extension Cube {

    /// 加 child（必要時先 insert 到 context）
    func addChild(_ child: Cube, in context: ModelContext? = nil) {
        if let ctx = context {
            let childId = child.id // ✅ 存成局部變數
            let fetch: [Cube]
            do {
                fetch = try ctx.fetch(FetchDescriptor<Cube>(
                    predicate: #Predicate { $0.id == childId }
                ))
            } catch {
                fetch = []
                print("Fetch failed: \(error)")
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
        }
    }

    /// 如果你過去寫 children(in:context)，替代用這個
    func childrenList() -> [Cube] {
        children
    }
}
