import SwiftData

struct PreviewContainer {

    static let container: ModelContainer = {
        let instance = Persistence(inMemory: true)
        return instance.container
    }()
}
