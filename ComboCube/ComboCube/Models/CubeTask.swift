import SwiftData

@Model
class CubeTask {
    var title: String
    var icon: String
    var duration: Int

    init(title: String, icon: String, duration: Int) {
        self.title = title
        self.icon = icon
        self.duration = duration
    }
}
