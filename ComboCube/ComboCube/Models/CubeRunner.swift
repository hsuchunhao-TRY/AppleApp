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

// MARK: - BaseTask (共同邏輯)
class BaseTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?

    var isRunning: Bool = false
    var onFinish: (() -> Void)?

    var timeRemaining: TimeInterval
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner?) {
        self.cube = cube
        self.runner = runner
        self.timeRemaining = Double(cube.duration)
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

// MARK: - DummyTask (不做事就是立即完成)
class DummyTask: BaseTask {
    override func start() {
        super.start()
        stop() // 立即 finish
    }
}

// MARK: - TimerTask (時間 countdown)
class TimerTask: BaseTask { }

// MARK: - CountdownTask (行為與 TimerTask 相同，可分開以後擴充)
class CountdownTask: BaseTask { }

// MARK: - RepetitionTask (根據 triggerCount 控制)
class RepetitionTask: BaseTask {
    override func start() {
        isRunning = true
        // 等 triggerCount 觸發完成
    }
}

// MARK: - ComboTask (只展開 children，不執行自己的 timer)
class ComboTask: BaseTask {
    override func start() {
        isRunning = true
        // Combo 不做 timer，直接讓 runner 執行下一個 task
        onFinish?()
    }
}

// MARK: - CubeRunner
@MainActor
class CubeRunner: ObservableObject {

    @Published var currentTask: CubeTask?
    @Published var isRunning: Bool = false

    private var taskQueue: [CubeTask] = []
    private var timerTask: Task<Void, Never>?

    // MARK: Start
    func start(cube: Cube) {
        let rootTask = cube.toTask(runner: self)
        taskQueue = expandTasks(root: rootTask)
        runNextTask()
    }

    // MARK: Run next
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

    // MARK: Timer loop
    func scheduleTimer(for task: CubeTask) {
        timerTask?.cancel()

        // ComboTask 不需要 timer
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

    // MARK: Combo expand
    func expandTasks(root: CubeTask) -> [CubeTask] {
        if root is ComboTask {
            return root.cube.children.flatMap { child in
                expandTasks(root: child.toTask(runner: self))
            }
        }
        return [root]
    }
}
