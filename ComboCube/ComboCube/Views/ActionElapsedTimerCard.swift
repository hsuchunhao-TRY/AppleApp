import SwiftUI

struct ActionElapsedTimerCard: View {
    let title: String
    let icon: String

    @State private var elapsedTime: TimeInterval = 0
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

            // Elapsed Time Display
            Text(timeString(elapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(20)
                .background(Capsule().fill(Color.green.opacity(0.2)))

            // Controls
            HStack(spacing: 30) {
                Button(action: toggleTimer) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                Button(action: resetTimer) {
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

    private func resetTimer() {
        elapsedTime = 0
        isRunning = false
        timer?.invalidate()
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
