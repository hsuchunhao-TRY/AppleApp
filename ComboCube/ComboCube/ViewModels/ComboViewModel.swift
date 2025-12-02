import SwiftData

@Observable
class ComboViewModel {

    let parent: Cube
    var context: ModelContext

    init(cube: Cube, context: ModelContext) {
        self.parent = cube
        self.context = context
    }

    func addChild(_ child: Cube) {
        parent.children.append(child)
        try? context.save()
    }

    func removeChild(_ child: Cube) {
        parent.children.removeAll { $0.id == child.id }
        try? context.save()
    }
}
