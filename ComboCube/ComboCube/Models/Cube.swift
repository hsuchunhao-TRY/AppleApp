import Foundation

enum CubeActionType: String {
    case combo
    case timer
    case countdown
    case repetitions
    case none
}

struct CubeAction {
    var actionType: CubeActionType
    var duration: TimeInterval? = nil      // 秒數，timer 或 countdown 用
    var repetitions: Int? = nil            // 重複次數，repetitions 用
    var cubeIDs: [UUID]? = nil             // combo 下的非 combo Cube 連結
}

struct Cube: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
    var backgroundColor: String
    var action: CubeAction
    var notes: String?             // 說明屬性
}
