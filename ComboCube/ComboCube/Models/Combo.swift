import SwiftData

@Model
class Combo {
    var title: String
    var tasks: [CubeTask] = []

    init(title: String) {
        self.title = title
    }
}
