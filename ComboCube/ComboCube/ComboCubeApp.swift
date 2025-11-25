import SwiftUI
import Combine

@main
struct ComboCubeApp: App {
    @StateObject private var store = CubeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
