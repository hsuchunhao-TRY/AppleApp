import Foundation
import SwiftData
internal import Combine

// MARK: - CubeTask 協議
protocol CubeTask: AnyObject {
    var cube: Cube { get }
    var isRunning: Bool { get }
    var onFinish: (() -> Void)? { get set }

    var timeRemaining: TimeInterval { get set }
    var completedCount: Int { get }

    func start()
    func pause()
    func resume()
    func stop()
    func triggerCount()
}

// MARK: - DummyTask
class DummyTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?
    var isRunning: Bool = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval = 0
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner? = nil) {
        self.cube = cube
        self.runner = runner
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func resume() { isRunning = true }
    func stop() { isRunning = false; onFinish?() }
    func triggerCount() {}
}

// MARK: - TimerTask
class TimerTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?
    var isRunning: Bool = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner? = nil) {
        self.cube = cube
        self.runner = runner
        self.timeRemaining = cube.duration ?? 0
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func resume() { isRunning = true }
    func stop() { isRunning = false; onFinish?() }
    func triggerCount() {}
}

// MARK: - CountdownTask
class CountdownTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?
    var isRunning: Bool = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner? = nil) {
        self.cube = cube
        self.runner = runner
        self.timeRemaining = cube.duration ?? 0
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func resume() { isRunning = true }
    func stop() { isRunning = false; onFinish?() }
    func triggerCount() {}
}

// MARK: - RepetitionTask
class RepetitionTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?
    var isRunning: Bool = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval
    var completedCount: Int

    init(cube: Cube, runner: CubeRunner? = nil) {
        self.cube = cube
        self.runner = runner
        self.timeRemaining = cube.duration ?? 0
        self.completedCount = 0
    }

    func start() { isRunning = true }
    func pause() { isRunning = false }
    func resume() { isRunning = true }
    func stop() { isRunning = false; onFinish?() }
    func triggerCount() { completedCount += 1 }
}

// MARK: - ComboTask
class ComboTask: CubeTask {
    let cube: Cube
    weak var runner: CubeRunner?
    var isRunning: Bool = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval = 0
    var completedCount: Int = 0

    init(cube: Cube, runner: CubeRunner) {
        self.cube = cube
        self.runner = runner
    }

    func start() {
        isRunning = true
        onFinish?()   // Combo 不運行自己的 timer
    }

    func pause() { isRunning = false }
    func resume() { isRunning = true }
    func stop() { isRunning = false; onFinish?() }
    func triggerCount() {}
}

// MARK: - CubeRunner
@MainActor
class CubeRunner: ObservableObject {

    @Published var currentTask: CubeTask?
    @Published var isRunning: Bool = false

    private var taskQueue: [CubeTask] = []
    private var timerTask: Task<Void, Never>?

    // MARK: - Start
    func start(cube: Cube) {
        let rootTask = cube.toTask(runner: self)
        taskQueue = expandTasks(root: rootTask)
        runNextTask()
    }

    // MARK: - Run Next Task
    func runNextTask() {
        guard !taskQueue.isEmpty else {
            currentTask = nil
            isRunning = false
            print("All tasks finished.")
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

    // MARK: - Timer Loop
    func scheduleTimer(for task: CubeTask) {
        timerTask?.cancel()

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

    // MARK: - Combo 展開 children
    func expandTasks(root: CubeTask) -> [CubeTask] {
        if let combo = root as? ComboTask {
            var result: [CubeTask] = []
            for child in combo.cube.children {
                result.append(contentsOf: expandTasks(root: child.toTask(runner: self)))
            }
            return result
        }
        return [root]
    }
}
