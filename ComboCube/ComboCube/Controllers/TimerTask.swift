import Foundation
import Combine

// MARK: - TimerTask
class TimerTask: CubeTask, ObservableObject {
    let cube: Cube
    var onFinish: (() -> Void)?
    
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var completedCount: Int = 0
    
    var isRunning = false
    private var timer: Timer?
    var uiTickInterval: TimeInterval = 0.05
    
    init(cube: Cube) {
        self.cube = cube
        self.timeRemaining = cube.duration ?? 0
    }
    
    func start() { resume() }
    
    func pause() {
        timer?.invalidate()
        isRunning = false
    }
    
    func resume() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: uiTickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = cube.duration ?? 0
        completedCount = 0
    }
    
    func triggerCount() {
        completedCount += 1
    }
    
    private func tick() {
        guard isRunning else { return }
        timeRemaining = max(0, timeRemaining - uiTickInterval)
        if timeRemaining <= 0 {
            stop()
            onFinish?()
        }
    }
}
