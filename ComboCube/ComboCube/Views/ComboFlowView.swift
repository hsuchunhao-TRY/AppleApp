import SwiftUI

struct ComboFlowView: View {
    let comboName: String
    let actions: [ActionCube] // ActionCube: title, icon, totalReps (可選)

    @State private var currentIndex: Int? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var completedReps: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var autoNext: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Combo: \(comboName)").font(.title2).bold()

            // Dice 按鈕
            Button(action: rollDice) {
                Text("🎲 Roll Dice")
                    .font(.largeTitle)
            }

            // Current Action Card
            if let index = currentIndex {
                let action = actions[index]
                VStack(spacing: 12) {
                    HStack {
                        Text(action.icon).font(.largeTitle)
                        Text(action.title).font(.title2).bold()
                        Spacer()
                    }

                    Text("Elapsed: \(timeString(elapsedTime))")
                        .font(.system(.body, design: .monospaced))

                    if let total = action.totalReps {
                        Text("Reps: \(completedReps) / \(total)")
                            .font(.headline)
                        ProgressView(value: Double(completedReps), total: Double(total))
                            .progressViewStyle(.linear)
                    } else {
                        Text("Reps: \(completedReps)").font(.headline)
                    }

                    HStack(spacing: 20) {
                        Button(action: toggleTimer) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        }
                        Button(action: incrementRep) {
                            Image(systemName: "plus.circle.fill")
                        }
                        Button(action: resetTimer) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }

            // Combo Progress
            Text("Combo Progress: \(currentIndex.map { $0 + 1 } ?? 0) / \(actions.count)")
                .font(.headline)

            Spacer()
        }
        .padding()
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Dice Logic
    private func rollDice() {
        guard !actions.isEmpty else { return }
        currentIndex = Int.random(in: 0..<actions.count)
        resetTimer()
    }

    // MARK: - Timer Logic
    private func toggleTimer() {
        isRunning ? pauseTimer() : startTimer()
    }

    private func startTimer() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            checkAutoNext()
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }

    private func incrementRep() {
        guard let index = currentIndex else { return }
        if let total = actions[index].totalReps, completedReps >= total { return }
        completedReps += 1
        checkAutoNext()
    }

    private func resetTimer() {
        elapsedTime = 0
        completedReps = 0
        isRunning = false
        timer?.invalidate()
    }

    // MARK: - Auto Next Logic
    private func checkAutoNext() {
        guard autoNext, let index = currentIndex else { return }
        if let total = actions[index].totalReps, completedReps >= total {
            moveToNext()
        }
    }

    private func moveToNext() {
        if let index = currentIndex, index + 1 < actions.count {
            currentIndex! += 1
        } else {
            currentIndex = nil
        }
        resetTimer()
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

// // ActionCube 結構
// struct ActionCube {
//     let title: String
//     let icon: String
//     let totalReps: Int?
// }
