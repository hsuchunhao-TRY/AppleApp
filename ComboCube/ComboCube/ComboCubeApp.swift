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
//        clearAllCubes(context: context)
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.container) // 注入 SwiftData container
        }
    }
}

func clearAllCubes(context: ModelContext) {
    // 1️⃣ 清除 Cube 資料
    let fetchRequest = FetchDescriptor<Cube>()
    if let cubes = try? context.fetch(fetchRequest) {
        cubes.forEach { cube in
            context.delete(cube)
        }
        try? context.save()
    }

    // 2️⃣ 重置初始化 flag
    UserDefaults.standard.removeObject(forKey: "didInitializeSampleCubes")
}
