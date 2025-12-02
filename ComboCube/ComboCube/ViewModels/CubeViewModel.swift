import SwiftData

@Observable
class CubeViewModel {

    var cubes: [Cube] = []
    var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        fetch()
    }

    func fetch() {
        let descriptor = FetchDescriptor<Cube>()
        cubes = (try? context.fetch(descriptor)) ?? []
    }

    func addCube(
        title: String,
        icon: String,
        color: String,
        actionType: CubeActionType
    ) {
        let cube = Cube(
            title: title,
            icon: icon,
            backgroundColor: color,
            actionType: actionType
        )

        context.insert(cube)
        save()
        fetch()
    }

    func delete(_ cube: Cube) {
        context.delete(cube)
        save()
        fetch()
    }

    func save() {
        try? context.save()
    }
}
