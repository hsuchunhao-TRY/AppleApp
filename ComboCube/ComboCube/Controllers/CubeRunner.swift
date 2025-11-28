import Foundation
import Combine

// MARK: - 協議
protocol CubeTask: AnyObject {
    var cube: Cube { get }
    var isRunning: Bool { get }
    var onFinish: (() -> Void)? { get set }
    
    // UI 可綁定
    var timeRemaining: TimeInterval { get }
    var completedCount: Int { get }

    func start()
    func pause()
    func resume()
    func stop()
    func triggerCount()  // 外部事件觸發
}

// MARK: - Runner
class CubeRunner: ObservableObject {
    @Published var currentTask: CubeTask?
    
    private var taskMap: [CubeActionType: (Cube, CubeRunner) -> CubeTask] = [:]
    
    init() {
        taskMap = [
            .combo: { cube, runner in ComboTask(cube: cube, runner: runner) },
            .timer: { cube, _ in TimerTask(cube: cube) },
            .countdown: { cube, _ in TimerTask(cube: cube) },
            .repetitions: { cube, _ in TimerTask(cube: cube) }
        ]
    }
    
    func taskFor(_ cube: Cube) -> CubeTask {
        if let factory = taskMap[cube.type] {
            return factory(cube, self)
        } else {
            return DummyTask(cube: cube)
        }
    }
    
    func start(_ cube: Cube) {
        let task = taskFor(cube)
        currentTask = task
        task.start()
    }
    
    func pause() { currentTask?.pause() }
    func resume() { currentTask?.resume() }
    func stop() { currentTask?.stop() }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
