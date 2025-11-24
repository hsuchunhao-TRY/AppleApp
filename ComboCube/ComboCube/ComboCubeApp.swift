import SwiftUI
import SwiftData

@main
struct ComboCubeApp: App {
    var body: some Scene {
        WindowGroup {
            ComboListView()
        }
        .modelContainer(for: [Combo.self, CubeTask.self])
    }
}
