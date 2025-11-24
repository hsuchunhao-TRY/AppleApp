import SwiftUI
import SwiftData

struct TaskGridView: View {
    var combo: Combo
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(combo.tasks) { task in
                    VStack {
                        Text(task.icon).font(.largeTitle)
                        Text(task.title).font(.headline)
                        Text("\(task.duration) min").font(.caption)
                    }
                    .padding()
                    .background(.green.opacity(0.2))
                    .cornerRadius(12)
                    .contextMenu {
                        Button(role: .destructive) {
                            context.delete(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(combo.title)
        .toolbar {
            Button(action: {
                addTask()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
    }

    private func addTask() {
        let newTask = CubeTask(title: "New Task", icon: "📦", duration: Int.random(in: 5...60))
        combo.tasks.append(newTask)
        context.insert(newTask)
    }
}
