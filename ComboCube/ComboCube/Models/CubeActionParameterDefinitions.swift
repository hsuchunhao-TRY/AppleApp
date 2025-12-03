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

struct CubeActionTemplate {
    let type: CubeActionType
    let parameters: [CubeActionParameter]
}

let cubeActionParameterDefinitions: [CubeActionTemplate] = [

    // Timer
    CubeActionTemplate(
        type: .timer,
        parameters: [
            CubeActionParameter(
                name: "Duration", type: .time(0), used: true, isHidden: false),
            CubeActionParameter(
                name: "Enable Sound", type: .toggle(false), used: true, isHidden: false),
            CubeActionParameter(
                name: "Progress", type: .progress(0.0), used: true, isHidden: false)
        ]
    ),

    // Countdown
    CubeActionTemplate(
        type: .countdown,
        parameters: [
            CubeActionParameter(
                name: "Countdown Time", type: .time(0), used: true, isHidden: false),
            CubeActionParameter(
                name: "Vibrate on Finish", type: .toggle(false), used: true, isHidden: false),
            CubeActionParameter(
                name: "Progress", type: .progress(0.0), used: true, isHidden: false)
        ]
    ),

    // Repetitions (單純計數)
    CubeActionTemplate(
        type: .repetitions,
        parameters: [
            CubeActionParameter(
                name: "Repetition Count", type: .value(1), used: true, isHidden: false),
            CubeActionParameter(
                name: "Progress", type: .progress(0.0), used: true, isHidden: false)
        ]
    ),

    // Combo (使用 loopCount)
    CubeActionTemplate(
        type: .combo,
        parameters: [
            CubeActionParameter(
                name: "Loop Count", type: .value(1), used: true, isHidden: false)
        ]
    ),

    // None
    CubeActionTemplate(
        type: .none,
        parameters: []
    )
]
