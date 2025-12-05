import Foundation
import Combine
import SwiftData

@MainActor
class ComboDetailViewModel: ObservableObject {

    // UI 綁定的屬性
    @Published var currentTask: CubeTask?
    @Published var isRunning: Bool = false

    // 執行器
    let runner = CubeRunner()

    private var cancellables = Set<AnyCancellable>()

    init() {
        bindRunner()
    }

    // 建立 runner → viewModel 的綁定
    private func bindRunner() {

        // 1. task 改變
        runner.$currentTask
            .receive(on: RunLoop.main)
            .sink { [weak self] task in
                self?.currentTask = task
            }
            .store(in: &cancellables)

        // 2. 運行狀態改變
        runner.$isRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] running in
                self?.isRunning = running
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API for View

    func start(cube: Cube) {
        runner.start(cube: cube)
    }

    func pause() { runner.pause() }
    func resume() { runner.resume() }
    func stop() { runner.stop() }
}
