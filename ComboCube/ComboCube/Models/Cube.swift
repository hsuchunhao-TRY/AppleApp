import Foundation
import Combine

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

class Cube: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var icon: String
    @Published var backgroundColor: String
    @Published var action: CubeAction         // 改名 action
    @Published var notes: String?             // 說明屬性
    
    init(title: String, icon: String, backgroundColor: String, action: CubeAction, notes: String? = nil) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.action = action
        self.notes = notes
    }
}
