// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CubeStore
    @State private var selectedComboID: UUID? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(store.cubes.filter { $0.action.actionType == .combo }) { combo in
                        ComboGridItemView(
                            combo: combo,
                            isSelected: combo.id == selectedComboID
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedComboID =
                                    (selectedComboID == combo.id) ? nil : combo.id
                            }
                        }
                    }
                }
                .padding()
            }

            if let comboID = selectedComboID,
               let combo = store.cubes.first(where: { $0.id == comboID }),
               let itemIDs = combo.action.cubeIDs
            {
                Divider().padding(.vertical, 8)

                Text("訓練內容：\(combo.title)")
                    .font(.headline)
                    .padding(.bottom, 6)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(itemIDs.enumerated()), id: \.element) { index, itemID in
                            if let itemCube = store.cubes.first(where: { $0.id == itemID }) {
                                ItemCubeView(itemCube: itemCube, order: index + 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 170)
            }
        }
        .navigationTitle("Combos")
    }
}

struct ComboGridItemView: View {
    let combo: Cube
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(combo.icon)
                .font(.largeTitle)
            Text(combo.title)
                .font(.headline)
                .lineLimit(2)
            Text("\(combo.action.cubeIDs?.count ?? 0) 項目")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(
            isSelected
                ? Color(hex: combo.backgroundColor).opacity(0.7)
                : Color(hex: combo.backgroundColor)
        )
        .cornerRadius(12)
        .shadow(radius: isSelected ? 6 : 2)
        .animation(.easeInOut, value: isSelected)
    }
}

struct ItemCubeView: View {
    let itemCube: Cube
    let order: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                Text(itemCube.icon)
                    .font(.largeTitle)
                Text(itemCube.title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(width: 110, height: 140)
            .background(Color(hex: itemCube.backgroundColor))
            .cornerRadius(12)
            .shadow(radius: 2)

            // 左上角排序 badge
            Text("\(order)")
                .font(.caption2)
                .padding(6)
                .background(Color.black.opacity(0.85))
                .foregroundColor(.white)
                .clipShape(Circle())
                .offset(x: -6, y: -6)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = CubeStore()
        store.loadDefaultCubes()
        return NavigationView {
            ContentView()
                .environmentObject(store)
        }
    }
}
