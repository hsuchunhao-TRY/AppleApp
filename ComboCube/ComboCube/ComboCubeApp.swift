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

// MARK: - 初始化 Sample Cubes，只在資料庫空的時候建立
@MainActor
func initializeSampleCubesIfNeeded(context: ModelContext) async {
    let flagKey = "didInitializeSampleCubes"
    if UserDefaults.standard.bool(forKey: flagKey) { return }

    do {
        let cubes = try context.fetch(FetchDescriptor<Cube>())
        if !cubes.isEmpty {
            UserDefaults.standard.set(true, forKey: flagKey)
            return
        }

        // ---------------------------
        // MARK: - Helper to insert Cube
        // ---------------------------
        func insertCube(_ cube: Cube) {
            context.insert(cube)
        }

        // ---------------------------
        // MARK: - Combo 1
        // ---------------------------
        let warmup10s = Cube(
            title: "熱身 10 秒",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10)]
        )

        let hiit1min = Cube(
            title: "高強度間歇 1 分鐘",
            icon: "⚡️",
            backgroundColor: "#FF0000",
            actionType: .timer,
            tags: ["interval", "hiit"],
            actionParameters: ["duration": .double(60)]
        )

        insertCube(warmup10s)
        insertCube(hiit1min)

        let combo1 = Cube(
            title: "間歇訓練",
            icon: "⚡️",
            backgroundColor: "#FFBF00",
            actionType: .combo,
            tags: ["combo", "hiit"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo1.appendChild(warmup10s)
        combo1.appendChild(hiit1min)
        insertCube(combo1)

        // ---------------------------
        // MARK: - Combo 2
        // ---------------------------
        let warmup10min = Cube(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10.0*60.0)]
        )

        let climb6_10km = Cube(
            title: "爬坡 6–10km",
            icon: "⛰️",
            backgroundColor: "#00FF00",
            actionType: .timer,
            tags: ["climb", "strength"],
            actionParameters: ["duration": .double(20.0*60.0)]
        )

        insertCube(warmup10min)
        insertCube(climb6_10km)

        let combo2 = Cube(
            title: "爬坡肌耐力",
            icon: "⛰️",
            backgroundColor: "#919E71",
            actionType: .combo,
            tags: ["combo", "climb"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo2.appendChild(warmup10min)
        combo2.appendChild(climb6_10km)
        insertCube(combo2)

        // ---------------------------
        // MARK: - Combo 3
        // ---------------------------
        let warmup10min2 = Cube(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10.0*60.0)]
        )

        let cadence95rpm = Cube(
            title: "踩踏節奏 95rpm",
            icon: "🎵",
            backgroundColor: "#0000FF",
            actionType: .timer,
            tags: ["cadence", "rhythm"],
            actionParameters: ["duration": .double(15.0*60.0)]
        )

        insertCube(warmup10min2)
        insertCube(cadence95rpm)

        let combo3 = Cube(
            title: "踩踏節奏提升",
            icon: "🎵",
            backgroundColor: "#CAC5DD",
            actionType: .combo,
            tags: ["combo", "cadence"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo3.appendChild(warmup10min2)
        combo3.appendChild(cadence95rpm)
        insertCube(combo3)

        // ---------------------------
        // MARK: - Dice Cube
        // ---------------------------
        let diceCube = Cube(
            title: "隨機訓練",
            icon: "🎲",
            backgroundColor: "#FF69B4",
            actionType: .dice,
            tags: ["dice"],
            actionParameters: [
                "possibleActions": .string("timer,countdown,repetitions")
            ]
        )

        insertCube(diceCube)

        // ---------------------------
        // MARK: - Finish
        // ---------------------------
        UserDefaults.standard.set(true, forKey: flagKey)
        print("🔥 Sample Cubes saved successfully!")

    } catch {
        print("❌ Failed to fetch or save sample cubes: \(error)")
    }
}
