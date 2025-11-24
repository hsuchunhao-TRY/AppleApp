import SwiftUI
import SwiftData

struct ComboListView: View {
    @Query(sort: \Combo.title) var combos: [Combo]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationView {
            List {
                ForEach(combos) { combo in
                    NavigationLink(combo.title) {
                        TaskGridView(combo: combo)
                    }
                }
            }
            .navigationTitle("Combos")
            .toolbar {
                Button(action: {
                    addCombo()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
    }

    private func addCombo() {
        let newCombo = Combo(title: "New Combo")
        context.insert(newCombo)
    }
}
