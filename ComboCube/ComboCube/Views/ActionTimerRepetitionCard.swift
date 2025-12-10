import SwiftUI

struct ActionTimerRepetitionCard: View {
    let title: String
    let icon: String
    let totalReps: Int? // 可選總次數限制

    @State private var elapsedTime: TimeInterval = 0
    @State private var completedReps: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(icon).font(.largeTitle)
                Text(title).font(.title2).bold()
                Spacer()
            }

            // Timer Display
            Text(timeString(elapsedTime))
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .padding(20)
                .background(Capsule().fill(Color.blue.opacity(0.2)))

            // Repetitions Display
            if let total = totalReps {
                Text("Repetitions: \(completedReps) / \(total)")
                    .font(.headline)
            } else {
                Text("Repetitions: \(completedReps)")
                    .font(.headline)
            }

            // Progress Bar for Reps (optional)
            if let total = totalReps {
                ProgressView(value: Double(completedReps), total: Double(total))
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
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

                Button(action: reset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Timer & Reps Logic
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
        if let total = totalReps, completedReps >= total { return }
        completedReps += 1
    }

    private func reset() {
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
