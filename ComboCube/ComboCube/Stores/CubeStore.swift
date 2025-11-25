import Foundation
import Combine

class CubeStore: ObservableObject {
    @Published var cubes: [Cube] = []

    // 建立單一 task cube
    func addItemCube(title: String,
                     icon: String,
                     backgroundColor: String,
                     duration: TimeInterval? = nil) -> Cube {
        let cube = Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            action: CubeAction(actionType: .timer, duration: duration)
        )
        cubes.append(cube)
        return cube
    }

    // 建立 combo cube
    func addComboCube(title: String,
                      icon: String,
                      backgroundColor: String,
                      notes: String? = nil,
                      itemIDs: [UUID]) -> Cube {
        let cube = Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            action: CubeAction(actionType: .combo, cubeIDs: itemIDs)
        )
        cubes.append(cube)
        return cube
    }

    func loadDefaultCubes() {
        // Task Cubes
        let warmup = addItemCube(title: "熱身 10 分鐘", icon: "🔥", backgroundColor: "#FFA500", duration: 10*60)
        let interval1 = addItemCube(title: "高強度間歇 1 分鐘", icon: "⚡️", backgroundColor: "#FF0000", duration: 1*60)
        let interval2 = addItemCube(title: "低強度騎乘 10 分鐘", icon: "💨", backgroundColor: "#FFFF00", duration: 10*60)
        let climb = addItemCube(title: "爬坡 6-10km", icon: "⛰️", backgroundColor: "#00FF00", duration: 20*60)
        let cadence = addItemCube(title: "踩踏節奏 95rpm", icon: "🎵", backgroundColor: "#0000FF", duration: 15*60)


        // Combo Cubes
        addComboCube(title: "間歇訓練", icon: "⚡️", backgroundColor: "#FF0000", notes: "...", itemIDs: [warmup.id, interval1.id, interval2.id])
        addComboCube(title: "爬坡肌耐力", icon: "⛰️", backgroundColor: "#00FF00", notes: "...", itemIDs: [warmup.id, climb.id])
        addComboCube(title: "踩踏節奏提升", icon: "🎵", backgroundColor: "#0000FF", notes: "...", itemIDs: [warmup.id, cadence.id])

    }
}
