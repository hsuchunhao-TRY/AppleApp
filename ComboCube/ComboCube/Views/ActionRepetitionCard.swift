import SwiftUI

struct ActionRepetitionCard: View {
    let title: String
    let icon: String
    let totalReps: Int? // 可以選擇有總次數或不限次數

    @State private var completedReps: Int = 0
    @State private var isRunning: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text(icon).font(.largeTitle)
                Text(title).font(.title2).bold()
                Spacer()
            }

            // Repetitions Display
            if let total = totalReps {
                Text("Repetitions: \(completedReps) / \(total)")
                    .font(.headline)
            } else {
                Text("Repetitions: \(completedReps)")
                    .font(.headline)
            }

            // Progress Bar (如果有總次數)
            if let total = totalReps {
                ProgressView(value: Double(completedReps), total: Double(total))
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
            }

            // Controls
            HStack(spacing: 30) {
                Button(action: { isRunning.toggle() }) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                Button(action: resetReps) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                }
                Button(action: incrementRep) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    // MARK: - Actions
    private func incrementRep() {
        if let total = totalReps, completedReps >= total { return }
        completedReps += 1
    }

    private func resetReps() {
        completedReps = 0
        isRunning = false
    }
}
