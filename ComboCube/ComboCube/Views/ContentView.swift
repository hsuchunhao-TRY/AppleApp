// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    // 明確指定 Cube 類型
    @Query(sort: [SortDescriptor(\Cube.title)])
    private var allCubes: [Cube]

    @State private var expandedComboIDs: Set<UUID> = []

    var combos: [Cube] {
        allCubes.filter { $0.type == .combo }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    ForEach(combos, id: \.id) { combo in
                        ComboWithTasksView(combo: combo, isExpanded: expandedComboIDs.contains(combo.id))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    if expandedComboIDs.contains(combo.id) {
                                        expandedComboIDs.remove(combo.id)
                                    } else {
                                        expandedComboIDs.insert(combo.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("Combos")
            .onAppear {
                Task {
                    await initializeSampleCubesIfNeeded(context: context)
                }
            }
        }
    }
}


// 初始化 Sample Cubes，只在資料庫空的時候建立
@MainActor
func initializeSampleCubesIfNeeded(context: ModelContext) async {
    do {
        let cubes = try context.fetch(FetchDescriptor<Cube>())
        if cubes.isEmpty {
            // Task Cubes
            let warmup = Cube(title: "熱身 10 分鐘", icon: "🔥", backgroundColor: "#FFA500", actionType: .timer, duration: 10*60)
            let interval1 = Cube(title: "高強度間歇 1 分鐘", icon: "⚡️", backgroundColor: "#FF0000", actionType: .timer, duration: 1*60)
            let interval2 = Cube(title: "低強度騎乘 10 分鐘", icon: "💨", backgroundColor: "#FFFF00", actionType: .timer, duration: 10*60)
            let climb = Cube(title: "爬坡 6-10km", icon: "⛰️", backgroundColor: "#00FF00", actionType: .timer, duration: 20*60)
            let cadence = Cube(title: "踩踏節奏 95rpm", icon: "🎵", backgroundColor: "#0000FF", actionType: .timer, duration: 15*60)

            // Combo Cubes
            let combo1 = Cube(title: "間歇訓練", icon: "⚡️", backgroundColor: "#FFBF00", actionType: .combo)
            combo1.children.append(contentsOf: [warmup, interval1, interval2])
            
            let combo2 = Cube(title: "爬坡肌耐力", icon: "⛰️", backgroundColor: "#919E71", actionType: .combo)
            combo2.children.append(contentsOf: [warmup, climb])
            
            let combo3 = Cube(title: "踩踏節奏提升", icon: "🎵", backgroundColor: "#CAC5DD", actionType: .combo)
            combo3.children.append(contentsOf: [warmup, cadence])

            // 儲存
            [warmup, interval1, interval2, climb, cadence, combo1, combo2, combo3].forEach { context.insert($0) }
            try context.save()
            print("Sample Cubes saved!")
        }
    } catch {
        print("Fetch or save failed: \(error)")
    }
}


import SwiftUI
import SwiftData

// Combo + Task
struct ComboWithTasksView: View {
    let combo: Cube
    let isExpanded: Bool


    @State private var showEdit = false

    private var taskCubes: [Cube] {
        combo.children
    }

    var body: some View {
        VStack(spacing: 8) {

            // Combo 卡片 + Edit 按鈕
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    CubeStyleView(cube: combo, style: .basic)
                    CubeStyleView(cube: combo, style: .large)
                    CubeStyleView(cube: combo, style: .compact)
                    CubeStyleView(cube: combo, style: .detailed)
                }

                Button {
                    showEdit = true
                } label: {
                    Image(systemName: "pencil")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }
                .padding(8)
            }

            // 展開顯示 Task Cubes
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(Array(taskCubes.enumerated()), id: \.element.id) { index, itemCube in
                        TaskCubeView(
                            itemCube: itemCube,
                            order: index + 1
                        )
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .sheet(isPresented: $showEdit) {
            CubeEditView(cube: combo)
        }
        .animation(.easeInOut, value: isExpanded)
    }

}

// Task Cube
struct TaskCubeView: View {
    let itemCube: Cube
    let order: Int
    let style: CubeStyle = .compact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CubeStyleView(cube: itemCube, style: style)
                .overlay(alignment: .topLeading) {
                    Text("\(order).")
                        .font(.caption)
                        .padding(6)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(6)
                        .padding(4)
                }
        }
        .padding()
        .background(Color(hex: itemCube.backgroundColor))  // <- 用 hex initializer
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
