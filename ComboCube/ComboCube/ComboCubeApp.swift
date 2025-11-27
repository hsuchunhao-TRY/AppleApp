// ComboCubeApp.swift
import SwiftUI
import SwiftData


@main
struct ComboCubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Cube.self)
        }
    }
}
