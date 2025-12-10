import SwiftUI
import AudioToolbox

struct MetronomeView: View {
    @State private var bpm: Double = 60
    @State private var isRunning = false
    @State private var beatIndex = 0
    @State private var timer: Timer?

    let beatsPerBar = 4

    var body: some View {
        VStack(spacing: 20) {
            Text("Metronome").font(.title2).bold()

            // BPM 調整
            HStack {
                Text("BPM: \(Int(bpm))")
                Slider(value: $bpm, in: 40...240, step: 1)
            }.padding(.horizontal)

            // 節拍圓圈
            HStack(spacing: 12) {
                ForEach(0..<beatsPerBar, id: \.self) { index in
                    Circle()
                        .fill(index == beatIndex ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }

            // 控制按鈕
            HStack(spacing: 40) {
                Button(action: toggleMetronome) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                Button(action: resetMetronome) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                }
            }
        }
        .padding()
        .onDisappear { timer?.invalidate() }
    }

    private func toggleMetronome() {
        isRunning ? pause() : start()
    }

    private func start() {
        isRunning = true
        timer?.invalidate()
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            beat()
        }
    }

    private func pause() {
        isRunning = false
        timer?.invalidate()
    }

    private func resetMetronome() {
        pause()
        beatIndex = 0
    }

    private func beat() {
        beatIndex = (beatIndex + 1) % beatsPerBar
        playClick()
    }

    private func playClick() {
        AudioServicesPlaySystemSound(1104)
    }
}
