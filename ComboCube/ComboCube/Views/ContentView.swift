// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CubeStore

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(store.cubes) { cube in
                    CubeGridItemView(cube: cube)
                }
            }
        }
    }
}

struct CubeGridItemView: View {
    let cube: Cube   // 直接使用 struct

    var body: some View {
        VStack {
            Text(cube.icon)
            Text(cube.title)
            if cube.action.actionType == .combo {
                Text("Combo with \(cube.action.cubeIDs?.count ?? 0) items")
            } else {
                Text(cube.notes ?? "")
            }
        }
        .padding()
        .background(Color(cube.backgroundColor))
        .cornerRadius(12)
    }
}

// Example usage in preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
