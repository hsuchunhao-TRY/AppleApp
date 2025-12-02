import SwiftUI
import SwiftData

@main
struct ComboCubeApp: App {
    // 使用單例 Persistence
    let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.container) // 注入 SwiftData container
        }
    }
}
