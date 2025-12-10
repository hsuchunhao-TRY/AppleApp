import SwiftUI

struct ComboActionCard: View {
    let comboTitle: String
    let actions: [ActionCube] // 每個 Cube: title, icon, totalReps
    @State private var currentIndex: Int = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var completedReps: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var autoNext: Bool = true

    var body: some View {
        VStack(spacing: 16) {

            // Combo Header
            HStack {
                Text(comboTitle)
                    .font(.title2)
                    .bold()
                Spacer()
                Text("Combo \(currentIndex + 1)/\(actions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Current Action
            if actions.indices.contains(currentIndex) {
                let action = actions[currentIndex]
                VStack(spacing: 12) {
                    HStack {
                        Text(action.icon).font(.largeTitle)
                        Text(action.title).font(.title3).bold()
                        Spacer()
                    }

                    // Timer Display
                    Text("⏱ \(timeString(elapsedTime))")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .padding(12)
                        .background(Capsule().fill(Color.blue.opacity(0.2)))

                    // Repetition Display
                    if let total = action.totalReps {
                        Text("🔁 Reps: \(completedReps)/\(total)")
                            .font(.headline)
                        ProgressView(value: Double(completedReps), total: Double(total))
                            .progressViewStyle(.linear)
                    } else {
                        Text("🔁 Reps: \(completedReps)")
                            .font(.headline)
                    }

                    // Controls
                    HStack(spacing: 20) {
                        Button(action: toggleTimer) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                        }
                        Button(action: incrementRep) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        Button(action: resetTimer) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                        }
                        Button(action: rollDice) {
                            Image(systemName: "die.face.6.fill")
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }

            Spacer()
        }
        .padding()
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Timer & Repetition Logic
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
        let action = actions[currentIndex]
        if let total = action.totalReps, completedReps >= total { return }
        completedReps += 1
        checkAutoNext()
    }

    private func resetTimer() {
        elapsedTime = 0
        completedReps = 0
        isRunning = false
        timer?.invalidate()
    }

    // MARK: - Dice / Auto Next
    private func rollDice() {
        guard !actions.isEmpty else { return }
        currentIndex = Int.random(in: 0..<actions.count)
        resetTimer()
    }

    private func checkAutoNext() {
        let action = actions[currentIndex]
        if autoNext, let total = action.totalReps, completedReps >= total {
            moveToNext()
        }
    }

    private func moveToNext() {
        if currentIndex + 1 < actions.count {
            currentIndex += 1
            resetTimer()
        } else {
            // Combo 完成
            currentIndex = 0
            resetTimer()
        }
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

// ActionCube 模型
struct ActionCube {
    let title: String
    let icon: String
    let totalReps: Int?
}
