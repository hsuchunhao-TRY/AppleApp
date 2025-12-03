//如要重新匯入資料
//UserDefaults.standard.removeObject(forKey: "didInitializeSampleCubes")


import SwiftUI
import SwiftData

@main
struct ComboCubeApp: App {
    // 使用單例 Persistence
    let persistence = Persistence.shared

    init() {
        let context = Persistence.shared.container.mainContext

        Task {
            await initializeSampleCubesIfNeeded(context: context)
        }
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.container) // 注入 SwiftData container
        }
    }
}
