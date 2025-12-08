import SwiftData
import Foundation

struct Persistence {
    static let shared = Persistence()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([Cube.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)

        do {
            // ✅ 必須加 try，並處理錯誤
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

//        // 若為 in-memory，可塞入測試資料
//        if inMemory {
//            SeedData.load(into: container.mainContext)
//        }
    }

    static var preview: ModelContainer {
        Persistence(inMemory: true).container
    }
}
