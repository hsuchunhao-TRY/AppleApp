import Foundation

// MARK: - DummyTask
class DummyTask: CubeTask {
    let cube: Cube
    var isRunning = false
    var onFinish: (() -> Void)?
    var timeRemaining: TimeInterval = 0
    var completedCount: Int = 0
    
    init(cube: Cube) { self.cube = cube }
    
    func start() { onFinish?() }
    func pause() {}
    func resume() {}
    func stop() {}
    func triggerCount() {}
}
