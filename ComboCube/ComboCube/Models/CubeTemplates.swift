import Foundation

enum CubeActionParameterType {
    case toggle(Bool)     // 開關
    case text(String)     // 文字
    case time(Double)     // 時間（秒）
    case value(Int)       // 數值
    case progress(Double) // 進度
}


struct CubeActionParameter: Identifiable {
    let id = UUID()
    let name: String
    var type: CubeActionParameterType
    let used: Bool       // 是否在此 action 中使用
    let isHidden: Bool   // 是否在 UI 中隱藏
}

// MARK: - Cube Template
struct CubeTemplate {
    let title: String
    let icon: String
    let backgroundColor: String
    let tags: [String]
    let actionType: CubeActionType
    let defaultParameters: [String: CodableValue]?

    func makeCube() -> Cube {
        Cube(
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            actionType: actionType,
            tags: tags,
            actionParameters: defaultParameters
        )
    }
    
    func makeCube(from template: CubeTemplate, parameters: [String: CodableValue]? = nil) -> Cube {
        var finalParameters = template.defaultParameters ?? [:]
        
        if let customParams = parameters {
            for (key, value) in customParams {
                finalParameters[key] = value
            }
        }

        return Cube(
            title: template.title,
            icon: template.icon,
            backgroundColor: template.backgroundColor,
            actionType: template.actionType,
            tags: template.tags,
            actionParameters: finalParameters
        )
    }
}

// MARK: - 定義 Cube 模板 for action
let cubeTemplates: [CubeTemplate] = [

    CubeTemplate(
        title: CubeActionType.combo.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.combo),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.combo).toHex() ?? "#FFBF00",
        tags: [],
        actionType: CubeActionType.combo,
        defaultParameters: [
            "loopCount": .int(1),
            "autoNextTask": .bool(false),
            "children": .string("[]") // 空陣列
        ]
    ),
    
    CubeTemplate(
        title: CubeActionType.dice.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.dice),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.dice).toHex() ?? "#8A2BE2",
        tags: [],
        actionType: CubeActionType.dice,
        defaultParameters: [
            "children": .string("[]") // 空陣列
        ]
    ),

    CubeTemplate(
        title: CubeActionType.timer.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.timer),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.timer).toHex() ?? "#00BFFF",
        tags: [],
        actionType: CubeActionType.timer,
        defaultParameters: [
            "duration": .double(60)
        ]
    ),

    CubeTemplate(
        title: CubeActionType.countdown.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.countdown),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.countdown).toHex() ?? "#FF6347",
        tags: [],
        actionType: CubeActionType.countdown,
        defaultParameters: [
            "duration": .double(60)
        ]
    ),

    CubeTemplate(
        title: CubeActionType.repetitions.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.repetitions),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.repetitions).toHex() ?? "#32CD32",
        tags: [],
        actionType: CubeActionType.repetitions,
        defaultParameters: [
            "tapCount": .int(0)
        ]
    ),

    CubeTemplate(
        title: CubeActionType.none.rawValue,
        icon: CubeUIManager.shared.getIcon(for: CubeActionType.none),
        backgroundColor: CubeUIManager.shared.getColor(for: CubeActionType.none).toHex() ?? "#D3D3D3",
        tags: [],
        actionType: CubeActionType.none,
        defaultParameters: [:]
    )
]
