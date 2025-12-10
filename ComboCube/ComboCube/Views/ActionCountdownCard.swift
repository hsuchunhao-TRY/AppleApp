import SwiftUI

struct ActionCountdownCard: View {
    let title: String
    let icon: String
    let duration: TimeInterval
    let loopCount: Int
    let autoNext: Bool

    @State private var remainingTime: TimeInterval
    @State private var isRunning: Bool = false
    @State private var timer: Timer?

    init(title: String, icon: String, duration: TimeInterval, loopCount: Int = 1, autoNext: Bool = false) {
        self.title = title
        self.icon = icon
        self.duration = duration
        self.loopCount = loopCount
        self.autoNext = autoNext
        _remainingTime = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(icon).font(.largeTitle)
                Text(title).font(.title2).bold()
                Spacer()
            }

            // Timer Display
            Text(timeString(remainingTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding(20)
                .background(Capsule().fill(Color.blue.opacity(0.2)))

            // Progress Bar
            ProgressView(value: remainingTime, total: duration)
                .progressViewStyle(.linear)
                .padding(.horizontal)

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

            // Optional Info
            HStack {
                if loopCount > 1 { Text("Loop: \(loopCount)") }
                if autoNext { Text("Auto Next") }
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Timer Logic
    private func toggleTimer() {
        if isRunning { pauseTimer() } else { startTimer() }
    }

    private func startTimer() {
        timer?.invalidate()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                isRunning = false
            }
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        isRunning = false
    }

    private func resetTimer() {
        timer?.invalidate()
        remainingTime = duration
        isRunning = false
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
