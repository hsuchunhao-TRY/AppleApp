import Foundation
import Combine

enum CubeActionType: String {
    case combo
    case timer
    case countdown
    case repetitions
    case none
}

class CubeAction {
    var actionType: CubeActionType
    var duration: TimeInterval? = nil      // 秒數，timer 或 countdown 用
    var repetitions: Int? = nil            // 重複次數，repetitions 用
    var cubeIDs: [UUID]? = nil             // combo 下的非 combo Cube 連結
    var notes: String? = nil               // 說明屬性
    
    init(actionType: CubeActionType,
         duration: TimeInterval? = nil,
         repetitions: Int? = nil,
         cubeIDs: [UUID]? = nil,
         notes: String? = nil) {
        self.actionType = actionType
        self.duration = duration
        self.repetitions = repetitions
        self.cubeIDs = cubeIDs
        self.notes = notes
    }
}

class Cube: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var icon: String
    @Published var backgroundColor: String
    @Published var actionInfo: CubeAction
    
    init(title: String, icon: String, backgroundColor: String, actionInfo: CubeAction) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.actionInfo = actionInfo
    }
}
