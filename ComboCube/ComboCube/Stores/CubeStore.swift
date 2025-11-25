import Foundation
import Combine

class CubeStore: ObservableObject {
    @Published var cubes: [Cube] = []

    // 建立單一 task cube
    func addItemCube(title: String,
                     icon: String,
                     backgroundColor: String,
                     notes: String? = nil,
                     actionType: CubeActionType = .none) -> Cube {
        let cube = Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            action: CubeAction(actionType: actionType),
            notes: notes
        )
        cubes.append(cube)
        return cube
    }

    // 建立 combo cube，連結多個 task cube
    func addComboCube(title: String,
                      icon: String,
                      backgroundColor: String,
                      notes: String? = nil,
                      cubeIDs: [UUID]) -> Cube {
        let cube = Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            action: CubeAction(actionType: .combo, cubeIDs: cubeIDs),
            notes: notes
        )
        cubes.append(cube)
        return cube
    }

    // 初始化內建 task 與 combo
    func loadDefaultCubes() {
        // 單一 task cubes
        let warmup = addItemCube(title: "熱身 10 分鐘", icon: "🔥", backgroundColor: "orange", notes: "熱身")
        let interval1 = addItemCube(title: "高強度間歇 1 分鐘", icon: "⚡️", backgroundColor: "red", notes: "間歇訓練")
        let interval2 = addItemCube(title: "低強度騎乘 10 分鐘", icon: "💨", backgroundColor: "yellow", notes: "恢復")
        let climb = addItemCube(title: "爬坡 6-10km", icon: "⛰️", backgroundColor: "green", notes: "腿部肌耐力")
        let cadence = addItemCube(title: "踩踏節奏 95rpm", icon: "🎵", backgroundColor: "blue", notes: "效率訓練")

        // Combo cubes
        addComboCube(title: "間歇訓練", icon: "⚡️", backgroundColor: "red", notes: "提升最大攝氧量與無氧耐力", cubeIDs: [warmup.id, interval1.id, interval2.id])
        addComboCube(title: "爬坡肌耐力", icon: "⛰️", backgroundColor: "green", notes: "增強腿部肌耐力", cubeIDs: [warmup.id, climb.id])
        addComboCube(title: "踩踏節奏提升", icon: "🎵", backgroundColor: "blue", notes: "提升踩踏順暢度與效率", cubeIDs: [warmup.id, cadence.id])
    }
}
