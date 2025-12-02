import SwiftData

enum SeedData {

    static func load(into context: ModelContext) {

        let sample = Cube(
            title: "Sample Combo",
            icon: "🔥",
            backgroundColor: "#FFDD55",
            actionType: .combo,
            children: []
        )

        context.insert(sample)
        
        try? context.save()
    }
}
