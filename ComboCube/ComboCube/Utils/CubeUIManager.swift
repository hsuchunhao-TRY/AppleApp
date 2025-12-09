import SwiftUI

// MARK: - 活動分類
enum Category: String {
    case fitness       // 健身
    case strength      // 重訓
    case walking       // 健走
    case running       // 跑步
    case cycling       // 自行車
    case spinning      // 飛輪
    case jumpRope      // 跳繩
    case yoga          // 瑜伽
    case cardio        // 心肺
    case dice          // 隨機/骰子
    case game          // 遊戲
    case study         // 自習
    case reading       // 閱讀
    case meditation    // 冥想/靜心
    case swimming      // 游泳
    case hiking        // 登山/健行
    case music         // 音樂/樂器
    case cooking       // 烹飪
}

// MARK: - CubeUIManager
class CubeUIManager {

    static let shared = CubeUIManager()
    
    private init() { }

    // MARK: - 顏色對應
    func getColor(for actionType: CubeActionType) -> Color {
        switch actionType {
        case .combo: return Color(hex: "#FFBF00")
        case .timer: return Color(hex: "#FF0000")
        case .countdown: return Color(hex: "#FFA500")
        case .repetitions: return Color(hex: "#00FF00")
        case .dice: return Color(hex: "#FF69B4")
        default: return Color.gray
        }
    }

    // MARK: - 顏色對應
    func getColor(for category: Category) -> Color {
        switch category {
        case .fitness:    return Color(hex: "#FF4500")   // 橘紅
        case .strength:   return Color(hex: "#8B4513")   // 棕
        case .walking:    return Color(hex: "#2E8B57")   // 綠
        case .running:    return Color(hex: "#FF6347")   // 番茄紅
        case .cycling:    return Color(hex: "#1E90FF")   // 藍
        case .spinning:   return Color(hex: "#9400D3")   // 紫
        case .jumpRope:   return Color(hex: "#FFD700")   // 金
        case .yoga:       return Color(hex: "#00CED1")   // 深青
        case .cardio:     return Color(hex: "#FF1493")   // 粉紅
        case .dice:       return Color(hex: "#FF69B4")   // 熱粉
        case .game:       return Color(hex: "#00FF7F")   // 淺綠
        case .study:      return Color(hex: "#708090")   // 灰藍
        case .reading:    return Color(hex: "#F5DEB3")   // 小麥色
        case .meditation: return Color(hex: "#9370DB")   // 紫水晶
        case .swimming:   return Color(hex: "#1E90FF")   // 藍
        case .hiking:     return Color(hex: "#556B2F")   // 橄欖綠
        case .music:      return Color(hex: "#FF8C00")   // 深橘
        case .cooking:    return Color(hex: "#DC143C")   // 猩紅
        }
    }

    // MARK: - SF Symbols 圖示對應 ActionType
    func getIcon(for actionType: CubeActionType) -> String {
        switch actionType {
        case .combo: return "square.grid.2x2"
        case .timer: return "timer"
        case .countdown: return "clock.arrow.circlepath"
        case .repetitions: return "repeat"
        case .dice: return "dice"
        default: return "questionmark"
        }
    }
    
    // MARK: - SF Symbols 對應
    func getIcon(for category: Category) -> String {
        switch category {
        case .fitness:    return "figure.strengthtraining.traditional"
        case .strength:   return "dumbbell"
        case .walking:    return "figure.walk"
        case .running:    return "figure.run"
        case .cycling:    return "bicycle"
        case .spinning:   return "figure.cooldown"
        case .jumpRope:   return "figure.jumprope"
        case .yoga:       return "figure.yoga"
        case .cardio:     return "heart.fill"
        case .dice:       return "die.face.6.fill"
        case .game:       return "gamecontroller"
        case .study:      return "books.vertical"
        case .reading:    return "book.fill"
        case .meditation: return "brain.head.profile"
        case .swimming:   return "figure.pool.swim"
        case .hiking:     return "figure.hiking"
        case .music:      return "music.note"
        case .cooking:    return "fork.knife"
        }
    }
}

// MARK: - CubeUIManager 顏色與圖示陣列
extension CubeUIManager {

    // MARK: - 顏色陣列
    static let backgroundOptions: [Color] = [.yellow, .orange, .blue, .green, .pink, Color(hex: "#FF4500")]
    static let colors: [Color] = [
//        .yellow,
        Color(hex: "#FF4500"), // 橘紅
        Color(hex: "#8B4513"), // 棕
        Color(hex: "#2E8B57"), // 綠
        Color(hex: "#FF6347"), // 番茄紅
        Color(hex: "#1E90FF"), // 藍
        Color(hex: "#9400D3"), // 紫
        Color(hex: "#FFD700"), // 金
        Color(hex: "#00CED1"), // 深青
        Color(hex: "#FF1493"), // 粉紅
        Color(hex: "#FF69B4"), // 熱粉
        Color(hex: "#00FF7F"), // 淺綠
        Color(hex: "#708090"), // 灰藍
        Color(hex: "#F5DEB3"), // 小麥色
        Color(hex: "#9370DB"), // 紫水晶
        Color(hex: "#1E90FF"), // 藍
        Color(hex: "#556B2F"), // 橄欖綠
        Color(hex: "#FF8C00"), // 深橘
        Color(hex: "#DC143C")  // 猩紅
    ]

    // MARK: - Icon 陣列 (SF Symbols)
    static let icons: [String] = [
        "figure.strengthtraining.traditional", // fitness
        "dumbbell",                            // strength
        "figure.walk",                         // walking
        "figure.run",                          // running
        "bicycle",                             // cycling
        "figure.cooldown",                     // spinning
        "figure.jumprope",                     // jumpRope
        "figure.yoga",                         // yoga
        "heart.fill",                          // cardio
        "die.face.6.fill",                     // dice
        "gamecontroller",                       // game
        "books.vertical",                       // study
        "book.fill",                            // reading
        "brain.head.profile",                   // meditation
        "figure.pool.swim",                     // swimming
        "figure.hiking",                        // hiking
        "music.note",                           // music
        "fork.knife"                            // cooking
    ]
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


import Foundation

// MARK: - 全域 CubeTemplate 管理器
struct CubeTemplateLibrary {

    // MARK: - 單例（可選）
    static let shared = CubeTemplateLibrary()

    // MARK: - 定義各種模板
    let warmup10s: CubeTemplate
    let hiit1min: CubeTemplate
    let comboInterval: CubeTemplate
    let warmup10min: CubeTemplate
    let climb6_10km: CubeTemplate
    let comboClimb: CubeTemplate
    let cadence95rpm: CubeTemplate
    let warmup10min2: CubeTemplate
    let comboCadence: CubeTemplate
    let dice: CubeTemplate

    // MARK: - 初始化模板
    private init() {
        warmup10s = CubeTemplate(
            title: "熱身 10 秒",
            icon: "🔥",
            backgroundColor: "#FFA500",
            tags: ["warmup", "easy"],
            actionType: .timer,
            defaultParameters: ["duration": .double(10)]
        )

        hiit1min = CubeTemplate(
            title: "高強度間歇 1 分鐘",
            icon: "⚡️",
            backgroundColor: "#FF0000",
            tags: ["interval", "hiit"],
            actionType: .timer,
            defaultParameters: ["duration": .double(60)]
        )

        comboInterval = CubeTemplate(
            title: "間歇訓練",
            icon: "⚡️",
            backgroundColor: "#FFBF00",
            tags: ["combo", "hiit"],
            actionType: .combo,
            defaultParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        warmup10min = CubeTemplate(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            tags: ["warmup", "easy"],
            actionType: .timer,
            defaultParameters: ["duration": .double(10.0*60.0)]
        )

        climb6_10km = CubeTemplate(
            title: "爬坡 6–10km",
            icon: "⛰️",
            backgroundColor: "#00FF00",
            tags: ["climb", "strength"],
            actionType: .timer,
            defaultParameters: ["duration": .double(20.0*60.0)]
        )

        comboClimb = CubeTemplate(
            title: "爬坡肌耐力",
            icon: "⛰️",
            backgroundColor: "#919E71",
            tags: ["combo", "climb"],
            actionType: .combo,
            defaultParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        cadence95rpm = CubeTemplate(
            title: "踩踏節奏 95rpm",
            icon: "🎵",
            backgroundColor: "#0000FF",
            tags: ["cadence", "rhythm"],
            actionType: .timer,
            defaultParameters: ["duration": .double(15.0*60.0)]
        )

        warmup10min2 = CubeTemplate(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            tags: ["warmup", "easy"],
            actionType: .timer,
            defaultParameters: ["duration": .double(10.0*60.0)]
        )

        comboCadence = CubeTemplate(
            title: "踩踏節奏提升",
            icon: "🎵",
            backgroundColor: "#CAC5DD",
            tags: ["combo", "cadence"],
            actionType: .combo,
            defaultParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        dice = CubeTemplate(
            title: "隨機訓練",
            icon: "🎲",
            backgroundColor: "#FF69B4",
            tags: ["dice"],
            actionType: .dice,
            defaultParameters: [
                "possibleActions": .string("timer,countdown,repetitions")
            ]
        )
    }

    // MARK: - 方便群組
    var allTemplates: [CubeTemplate] {
        [
            warmup10s, hiit1min, comboInterval,
            warmup10min, climb6_10km, comboClimb,
            cadence95rpm, warmup10min2, comboCadence,
            dice
        ]
    }
}
