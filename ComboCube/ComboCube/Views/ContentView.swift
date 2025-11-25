// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var store = CubeStore()

    // Grid layout
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(store.cubes) { cube in
                        CubeGridItemView(cube: cube)
                    }
                }
                .padding()
            }
            .navigationTitle("Cubes")
        }
        .onAppear {
            store.loadDefaultCubes() // 載入內建 combo & task
        }
    }
}

struct CubeGridItemView: View {
    @ObservedObject var cube: Cube

    var body: some View {
        VStack(spacing: 10) {
            Text(cube.icon)
                .font(.largeTitle)
            Text(cube.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            if let notes = cube.actionInfo.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(cube.backgroundColor))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// Example usage in preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
