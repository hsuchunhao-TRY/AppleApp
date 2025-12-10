import SwiftUI

struct ActionTimerCard: View {
    @State private var remainingTime: TimeInterval
    @State private var isRunning: Bool = false
    let title: String
    let icon: String

    @State private var timer: Timer?

    init(title: String, icon: String, duration: TimeInterval) {
        self.title = title
        self.icon = icon
        _remainingTime = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 顯示圖示與標題
            HStack {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.headline)
            }

            // 倒數時間顯示
            Text(timeString(remainingTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.2)))
            
            // 進度條
            ProgressView(value: remainingTime, total: 60) // 假設最大 60 秒
                .progressViewStyle(.linear)
                .padding(.horizontal)

            // 控制按鈕
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
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    timer?.invalidate()
                    isRunning = false
                }
            }
            isRunning = true
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        remainingTime = 60
        isRunning = false
    }

    private func timeString(_ seconds: TimeInterval) -> String {
        let min = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
