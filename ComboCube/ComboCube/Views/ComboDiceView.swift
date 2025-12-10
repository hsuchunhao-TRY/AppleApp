import SwiftUI

struct ComboDiceView: View {
    let comboName: String
    let actions: [String] // 動作名稱，簡化示範
    @State private var currentIndex: Int? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var completedReps: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Text("Combo: \(comboName)").font(.title2).bold()

            // Dice
            Button(action: rollDice) {
                Text("🎲 Roll Dice")
                    .font(.largeTitle)
            }

            // Current Action Display
            if let index = currentIndex {
                VStack(spacing: 8) {
                    Text("Current Action: \(actions[index])")
                        .font(.headline)

                    Text("Elapsed: \(timeString(elapsedTime))")
                        .font(.system(.body, design: .monospaced))

                    Text("Reps: \(completedReps)")
                        .font(.body)

                    // Controls
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
        }
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }

    private func incrementRep() {
        completedReps += 1
    }

    private func resetTimer() {
        elapsedTime = 0
        completedReps = 0
        isRunning = false
        timer?.invalidate()
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
