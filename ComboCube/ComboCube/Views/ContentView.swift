// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ComboPagerView()
            .background(Color.black.opacity(0.05))
    }
}

struct ComboPagerView: View {
    @Environment(\.modelContext) private var context

    // filter by rawValue to avoid the macro key-path enum issue
    @Query(
        filter: #Predicate<Cube> { $0.actionType == "combo" },
        sort: [SortDescriptor(\Cube.title)]
    )
    private var combos: [Cube]

    @State private var currentIndex: Int = 0
    @State private var showEdit: Bool = false
    @State private var showDetailPage: Bool = false
    @State private var showAddMenu: Bool = false

    @State private var isUnlocked: Bool = false

    @State private var dragDirectionLocked = false
    @State private var isVertical = false

    // layout constants
    let previewHeight: CGFloat = 60
    let horizontalPadding: CGFloat = 20
    let verticalSpacing: CGFloat = 8
    let bottomButtonsHeight: CGFloat = 64

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ✅ Combo 主區域（會被往上擠）
                VStack(spacing: verticalSpacing) {
                    // 上方 Preview
                    if let prev = previousCombo {
                        ComboTopBottomPreview(cube: prev)
                            .frame(height: previewHeight)
                            .padding(.horizontal, horizontalPadding)
                    }

                    // 中間 Combo
                    if let current = currentCombo {
                        ComboDetailCardView(cube: current)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalSpacing)
                            .onTapGesture {
                                if isUnlocked {
                                    showEdit = true
                                } else {
                                    showDetailPage = true
                                }
                            }
                    }

                    // 下方 Preview
                    if let next = nextCombo {
                        ComboTopBottomPreview(cube: next)
                            .frame(height: previewHeight)
                            .padding(.horizontal, horizontalPadding)
                    }
                }
                .frame(maxHeight: .infinity)

                // ✅ 選單：現在是「真的佔高度」，不再覆蓋 combo
                if showAddMenu {
                    VStack(alignment: .leading, spacing: 12) {
                        addMenuButton(title: "Combo", icon: "square.grid.2x2", type: .combo)
                        addMenuButton(title: "Timer", icon: "timer", type: .timer)
                        addMenuButton(title: "Countdown", icon: "clock.arrow.circlepath", type: .countdown)
                        addMenuButton(title: "Repetitions", icon: "repeat", type: .repetitions)
                    }
                    .padding(12)
                    .background(Color("AppBackground"))
                    .cornerRadius(16)
                    .padding(.horizontal, horizontalPadding)
                    .transition(.move(edge: .bottom))
                }

                // ✅ 底部按鈕列（永遠在最下面）
                HStack {
                    if isUnlocked {
                        Button {
                            withAnimation(.spring()) {
                                showAddMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }

                    Spacer()

                    Button {
                        toggleLockState()
                        withAnimation { showAddMenu = false }
                    } label: {
                        Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(isUnlocked ? .green : .gray)
                            .clipShape(Circle())
                    }
                }
                .frame(height: bottomButtonsHeight)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .gesture(
                DragGesture()
                    .onChanged { handleDragChanged($0) }
                    .onEnded { handleDragEnded($0) }
            )
        }

    }

    // MARK: helpers
    var currentCombo: Cube? {
        guard !combos.isEmpty else { return nil }
        // ensure currentIndex stays in bounds
        if currentIndex < 0 { currentIndex = 0 }
        if currentIndex >= combos.count { currentIndex = combos.count - 1 }
        return combos[currentIndex]
    }

    var previousCombo: Cube? {
        guard combos.indices.contains(currentIndex - 1) else { return nil }
        return combos[currentIndex - 1]
    }

    var nextCombo: Cube? {
        guard combos.indices.contains(currentIndex + 1) else { return nil }
        return combos[currentIndex + 1]
    }

    func goNext() {
        guard currentIndex < combos.count - 1 else { return }
        withAnimation(.spring()) { currentIndex += 1 }
    }
    func goPrev() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring()) { currentIndex -= 1 }
    }

    func toggleLockState() {
        isUnlocked.toggle()
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    func handleDragChanged(_ value: DragGesture.Value) {
        if !dragDirectionLocked {
            isVertical = abs(value.translation.height) > abs(value.translation.width)
            dragDirectionLocked = true
        }
    }

    func handleDragEnded(_ value: DragGesture.Value) {
        dragDirectionLocked = false
        if isVertical {
            if value.translation.height < -50 { goNext() }
            if value.translation.height > 50 { goPrev() }
        }
    }

    // addMenuButton + addNewItem (kept from your existing logic)
    @ViewBuilder
    func addMenuButton(title: String, icon: String, type: CubeActionType) -> some View {
        Button {
            addNewItem(type: type)
            withAnimation { showAddMenu = false }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 28)
                Text(title).font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    func addNewItem(type: CubeActionType) {
        var params: [String: CodableValue] = [:]
        switch type {
        case .combo:
            params["loopCount"] = .int(1)
            params["autoNextTask"] = .bool(false)
        case .timer, .countdown:
            params["duration"] = .double(60)
            params["durationEn"] = .bool(true)
            params["durationProgressEn"] = .bool(true)
        case .repetitions:
            params["tapCount"] = .int(0)
            params["tapCountEn"] = .bool(false)
            params["tapCountProgressEn"] = .bool(false)
        case .dice:
            params["possibleActions"] = .string("combo,timer,countdown,repetitions")
        default: break
        }

        let newCube = Cube(title: type.rawValue.capitalized,
                           icon: "⚡️",
                           backgroundColor: "#FFBF00",
                           actionType: type,
                           tags: [])
        let action = CubeAction(type: type, parameters: params)
        newCube.actions.append(action)

        context.insert(newCube)
        try? context.save()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            currentIndex = max(0, combos.count - 1)
        }
    }
}


// MARK: - 上下 Preview 卡片
struct ComboTopBottomPreview: View {
    let cube: Cube

    var body: some View {
        HStack(spacing: 12) {
            Text(cube.icon)
                .font(.title2)
            Text(cube.title)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color(hex: cube.backgroundColor).opacity(0.35))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}

// MARK: - 中間 Combo 內容
struct ComboDetailCardView: View {
    let cube: Cube
    let onRun: () -> Void = {}
    let onEdit: () -> Void = {}

    // 取出第一個 action
    private var action: CubeAction? { cube.actions.first }

    private var duration: Double {
        if let val = action?.parameters?["duration"]?.value as? Double { return val }
        return 0
    }

    private var loopCount: Int {
        if let val = action?.parameters?["loopCount"]?.value as? Int { return val }
        return 1
    }

    private var autoNextTask: Bool {
        if let val = action?.parameters?["autoNextTask"]?.value as? Bool { return val }
        return false
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
            }
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                let totalItems = cube.children.count
                let totalTime = cube.children.compactMap { $0.actions.first?.parameters?["duration"]?.value as? Double }.reduce(0, +)

                HStack {
                    Text("Items: \(totalItems)").font(.headline)
                    Spacer()
                    Text("Total: \(Int(totalTime / 60)) min").font(.headline)
                }
                .padding(.vertical, 4)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(cube.children) { child in
                            let childAction = child.actions.first
                            let childDuration = childAction?.parameters?["duration"]?.value as? Double ?? 0
                            HStack {
                                Text(child.icon)
                                Text(child.title)
                                Spacer()
                                if childDuration > 0 {
                                    Text("\(Int(childDuration / 60)) min").foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: cube.backgroundColor))
        .cornerRadius(16)
    }
}

struct ComboDetailFullPageView: View {
    let cube: Cube
    @Environment(\.dismiss) private var dismiss
    @State private var tasks: [TaskItem] = []

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
                Button("Close") { dismiss() }
            }
            .padding()

            Divider()

            let totalItems = tasks.count
            let totalTime = tasks.compactMap { $0.duration }.reduce(0, +)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Items: \(totalItems)").font(.headline)
                    Spacer()
                    Text("Total: \(Int(totalTime / 60)) min").font(.headline)
                }
                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(tasks.indices, id: \.self) { i in
                            let task = tasks[i]
                            HStack {
                                Text(task.icon)
                                Text(task.title)
                                Spacer()

                                switch task.status {
                                case .notStarted:
                                    if let d = task.duration {
                                        Text("\(Int(d / 60)) min").foregroundColor(.secondary)
                                    }
                                case .inProgress:
                                    Text(timeString(from: task.remaining)).foregroundColor(.blue)
                                case .completed:
                                    Text("Done").foregroundColor(.green)
                                }

                                Button(task.status == .inProgress ? "Pause" : "Start") {
                                    startTask(at: i)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            Divider()

            HStack {
                Button("Edit") {}
                    .buttonStyle(.bordered)
                Spacer()
                Button("Run All") {
                    for i in tasks.indices { startTask(at: i) }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: cube.backgroundColor).opacity(0.35))
        .onAppear {
            tasks = cube.children.map { child in
                let action = child.actions.first
                let duration = action?.parameters?["duration"]?.value as? Double
                return TaskItem(cube: child, duration: duration)
            }
        }
    }

    func startTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        var task = tasks[index]

        switch task.status {
        case .completed: return
        case .inProgress:
            task.status = .notStarted
            tasks[index] = task
            return
        case .notStarted: task.status = .inProgress
        }

        tasks[index] = task

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                guard tasks.indices.contains(index) else { timer.invalidate(); return }
                var task = tasks[index]
                guard task.status == .inProgress else { timer.invalidate(); return }

                if task.remaining > 0 { task.remaining -= 1 }
                else { task.status = .completed; timer.invalidate() }

                tasks[index] = task
            }
        }
    }

    func timeString(from seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct TaskItem: Identifiable {
    let id: UUID
    let icon: String
    let title: String
    let duration: TimeInterval?

    var remaining: TimeInterval
    var status: TaskStatus

    init(cube: Cube, duration: TimeInterval?) {
        self.id = cube.id
        self.icon = cube.icon
        self.title = cube.title
        self.duration = duration
        self.remaining = duration ?? 0
        self.status = .notStarted
    }
}

enum TaskStatus { case notStarted, inProgress, completed }


// 初始化 Sample Cubes，只在資料庫空的時候建立
@MainActor
func initializeSampleCubesIfNeeded(context: ModelContext) async {
    let flagKey = "didInitializeSampleCubes"
    if UserDefaults.standard.bool(forKey: flagKey) { return }

    do {
        let cubes = try context.fetch(FetchDescriptor<Cube>())
        if !cubes.isEmpty {
            UserDefaults.standard.set(true, forKey: flagKey)
            return
        }

        // MARK: - Timer Cubes
        let warmup10s = Cube(title: "熱身 10 秒", icon: "🔥", backgroundColor: "#FFA500", actionType: .timer, tags: ["warmup", "easy"])
        warmup10s.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(10)]))

        let warmup10min = Cube(title: "熱身 10 分鐘", icon: "🔥", backgroundColor: "#FFA500", actionType: .timer, tags: ["warmup", "easy"])
        warmup10min.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(10*60)]))

        let interval1 = Cube(title: "高強度間歇 1 分鐘", icon: "⚡️", backgroundColor: "#FF0000", actionType: .timer, tags: ["interval", "hiit"])
        interval1.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(60)]))

        let interval2 = Cube(title: "低強度騎乘 10 分鐘", icon: "💨", backgroundColor: "#FFFF00", actionType: .timer, tags: ["low", "recovery"])
        interval2.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(10*60)]))

        let climb = Cube(title: "爬坡 6-10km", icon: "⛰️", backgroundColor: "#00FF00", actionType: .timer, tags: ["climb", "strength"])
        climb.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(20*60)]))

        let cadence = Cube(title: "踩踏節奏 95rpm", icon: "🎵", backgroundColor: "#0000FF", actionType: .timer, tags: ["cadence", "rhythm"])
        cadence.addAction(CubeAction(type: .timer, parameters: ["duration": CodableValue(15*60)]))

        // MARK: - Combo Cubes
        let combo1 = Cube(title: "間歇訓練", icon: "⚡️", backgroundColor: "#FFBF00", actionType: .combo, tags: ["combo", "hiit"])
        combo1.addAction(CubeAction(type: .combo, parameters: ["loopCount": CodableValue(1), "autoNextTask": CodableValue(true)]))
        combo1.children.append(contentsOf: [warmup10min, interval1, interval2])

        let combo2 = Cube(title: "爬坡肌耐力", icon: "⛰️", backgroundColor: "#919E71", actionType: .combo, tags: ["combo", "climb"])
        combo2.addAction(CubeAction(type: .combo, parameters: ["loopCount": CodableValue(1), "autoNextTask": CodableValue(true)]))
        combo2.children.append(contentsOf: [warmup10min, climb])

        let combo3 = Cube(title: "踩踏節奏提升", icon: "🎵", backgroundColor: "#CAC5DD", actionType: .combo, tags: ["combo", "cadence"])
        combo3.addAction(CubeAction(type: .combo, parameters: ["loopCount": CodableValue(1), "autoNextTask": CodableValue(true)]))
        combo3.children.append(contentsOf: [warmup10min, cadence])

        // MARK: - Dice Cube 範例
        let diceCube = Cube(title: "隨機訓練", icon: "🎲", backgroundColor: "#FF69B4", actionType: .dice, tags: ["dice"])
        diceCube.addAction(CubeAction(type: .dice, parameters: ["possibleActions": CodableValue(["timer", "countdown", "repetitions"])]))

        // MARK: - Insert all
        let allCubes = [warmup10s, warmup10min, interval1, interval2, climb, cadence, combo1, combo2, combo3, diceCube]
        allCubes.forEach { context.insert($0) }

        try context.save()
        UserDefaults.standard.set(true, forKey: flagKey)
        print("🔥 Sample Cubes saved successfully!")
    } catch {
        print("❌ Failed to fetch or save sample cubes: \(error)")
    }
}
