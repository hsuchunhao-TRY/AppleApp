import Foundation
import Combine

// MARK: - ComboTask
class ComboTask: CubeTask, ObservableObject {
    let cube: Cube
    var onFinish: (() -> Void)?
    
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var completedCount: Int = 0
    
    var isRunning = false
    private var childTasks: [CubeTask] = []
    private var currentIndex = 0
    private weak var runner: CubeRunner?
    
    init(cube: Cube, runner: CubeRunner) {
        self.cube = cube
        self.runner = runner
        self.childTasks = cube.children.map { runner.taskFor($0) }
    }
    
    func start() { resume() }
    
    func pause() {
        isRunning = false
        childTasks[safe: currentIndex]?.pause()
    }
    
    func resume() {
        guard !isRunning else { return }
        isRunning = true
        runNext()
    }
    
    func stop() {
        isRunning = false
        childTasks.forEach { $0.stop() }
        currentIndex = 0
        timeRemaining = 0
        completedCount = 0
    }
    
    func triggerCount() {
        childTasks[safe: currentIndex]?.triggerCount()
        completedCount = childTasks.reduce(0) { $0 + $1.completedCount }
    }
    
    private func runNext() {
        guard isRunning else { return }
        guard currentIndex < childTasks.count else {
            isRunning = false
            onFinish?()
            return
        }
        
        let task = childTasks[currentIndex]
        task.onFinish = { [weak self] in
            self?.currentIndex += 1
            self?.runNext()
        }
        task.resume()
        
        // 更新總時間
        timeRemaining = childTasks.dropFirst(currentIndex).reduce(0) { $0 + $1.timeRemaining }
    }
}
