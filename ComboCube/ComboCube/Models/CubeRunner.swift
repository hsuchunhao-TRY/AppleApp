import Foundation
import SwiftData
import Combine

// MARK: - CubeTask Protocol
protocol CubeTask: AnyObject {
    var cube: Cube { get }
    var runner: CubeRunner? { get set }

    var isRunning: Bool { get set }
    var onFinish: (() -> Void)? { get set }

    var timeRemaining: TimeInterval { get set }
    var completedCount: Int { get set }

    func start()
    func pause()
    func resume()
    func stop()

    func triggerCount()
}

// MARK: - BaseTask
class BaseTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?

    var isRunning: Bool = false
    var onFinish: (() -> Void)?

    var timeRemaining: TimeInterval = 0
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner?) {
        self.cube = cube
        self.runner = runner
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func resume() { isRunning = true }

    func stop() {
        isRunning = false
        onFinish?()
    }

    func triggerCount() {
        completedCount += 1
    }
}

// MARK: - 任務類型
class DummyTask: BaseTask {
    override func start() {
        super.start()
        stop()
    }
}

class TimerTask: BaseTask { }
class CountdownTask: BaseTask { }

class RepetitionTask: BaseTask {
    override func start() {
        isRunning = true
    }
}

class ComboTask: BaseTask {
    override func start() {
        isRunning = true
        onFinish?()   // ✅ Combo 本身不計時，秒過
    }
}

// MARK: - CubeRunner
@MainActor
class CubeRunner: ObservableObject {

    @Published var currentTask: CubeTask?
    @Published var isRunning: Bool = false

    private var taskQueue: [CubeTask] = []
    private var timerTask: Task<Void, Never>?

    /// ✅ 所有 Cube 統一由外部灌入（List 頁初始化一次）
    var cubesByID: [UUID: Cube] = [:]

    // MARK: - Start
    func start(cube: Cube) {
        let rootTask = cube.toTask(runner: self)
        taskQueue = expandTasks(root: rootTask)
        runNextTask()
    }

    // MARK: - Run next
    func runNextTask() {
        guard !taskQueue.isEmpty else {
            currentTask = nil
            isRunning = false
            print("🎉 All tasks finished.")
            return
        }

        let next = taskQueue.removeFirst()
        currentTask = next
        isRunning = true

        next.onFinish = { [weak self] in
            Task { @MainActor in
                self?.runNextTask()
            }
        }

        next.start()
        scheduleTimer(for: next)
    }

    // MARK: - Timer loop
    func scheduleTimer(for task: CubeTask) {
        timerTask?.cancel()
        if task is ComboTask { return }

        timerTask = Task { @MainActor in
            while task.isRunning, isRunning, task.timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                task.timeRemaining -= 1
            }

            if task.isRunning {
                task.stop()
            }
        }
    }

    func pause() {
        isRunning = false
        currentTask?.pause()
    }

    func resume() {
        isRunning = true
        currentTask?.resume()
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        currentTask?.stop()
        taskQueue.removeAll()
    }

    // MARK: - ✅ Combo 展開（正式對齊 childrenIDs）
    func expandTasks(root: CubeTask) -> [CubeTask] {

        // ✅ Combo → 遞迴展開 childrenIDs
        if let combo = root as? ComboTask {

            var tasks: [CubeTask] = []

            for id in combo.cube.childrenIDs {
                guard let childCube = cubesByID[id] else { continue }

                let childTask = childCube.toTask(runner: self)
                let expanded = expandTasks(root: childTask)
                tasks.append(contentsOf: expanded)
            }

            return tasks
        }

        // ✅ 非 Combo → 直接回傳
        return [root]
    }
}

// MARK: - Cube → Task 工廠
extension Cube {

    func toTask(runner: CubeRunner?) -> CubeTask {

        let type = CubeActionType(rawValue: actionType) ?? .unknown
        let params = parseActionParameters(actionParameters)

        switch type {

        case .combo:
            return ComboTask(cube: self, runner: runner)

        case .timer:
            let task = TimerTask(cube: self, runner: runner)
            if let d = params["duration"] as? Double {
                task.timeRemaining = d
            }
            return task

        case .countdown:
            let task = CountdownTask(cube: self, runner: runner)
            if let d = params["duration"] as? Double {
                task.timeRemaining = d
            }
            return task

        case .repetitions:
            let task = RepetitionTask(cube: self, runner: runner)
            if let c = params["tapCount"] as? Int {
                task.timeRemaining = Double(c)
                task.completedCount = 0
            }
            return task

        default:
            return DummyTask(cube: self, runner: runner)
        }
    }

    func parseActionParameters(_ data: Data?) -> [String: Any] {
        guard
            let data,
            let obj = try? JSONSerialization.jsonObject(with: data),
            let dict = obj as? [String: Any]
        else {
            return [:]
        }
        return dict
    }
}
