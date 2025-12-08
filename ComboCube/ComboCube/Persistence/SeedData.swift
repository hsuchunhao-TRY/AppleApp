import SwiftData

//enum SeedData {
//
//    static func load(into context: ModelContext) {
//        // 建立 Sample Cube
//        let sample = Cube(
//            title: "Sample Combo",
//            icon: "🔥",
//            backgroundColor: "#FFDD55",
//            actionType: .combo
//        )
//
//        // 可以建立子 Cube
//        let childCube = Cube(
//            title: "Child Timer",
//            icon: "⏱️",
//            backgroundColor: "#55DDFF",
//            actionType: .timer
//        )
//        
//        // 建立 action 參數
//        let timerAction = CubeAction(type: .timer, parameters: ["Duration": .double(10)])
//        childCube.addAction(timerAction)
//        
//        // 將子 cube 加入 sample 的 children
//        sample.children.append(childCube)
//        
//        // 插入 context
//        context.insert(sample)
//        context.insert(childCube)
//        context.insert(timerAction)
//        
//        // 儲存
//        try? context.save()
//    }
//}
