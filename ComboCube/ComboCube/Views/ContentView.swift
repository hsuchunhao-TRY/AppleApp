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

    @Query(
        filter: #Predicate<Cube> { $0.actionType == "combo" },
        sort: [SortDescriptor(\Cube.title)]
    )
    private var combos: [Cube]

    @State private var currentIndex: Int = 0
    @State private var showEdit: Bool = false
    @State private var showDetailPage: Bool = false
    @State private var showAddMenu: Bool = false
    @State private var editingCube: Cube? = nil   // <- 新增

    @State private var isUnlocked: Bool = false
    @State private var dragDirectionLocked = false
    @State private var isVertical = false

    // layout constants
    let previewHeight: CGFloat = 60
    let horizontalPadding: CGFloat = 20
    let verticalSpacing: CGFloat = 8
    let bottomButtonsHeight: CGFloat = 64
    let addMenuMaxHeight = UIScreen.main.bounds.height * 0.4

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Combo 主區域
                VStack(spacing: verticalSpacing) {
                    if let prev = previousCombo {
                        ComboTopBottomPreview(cube: prev)
                            .frame(height: previewHeight)
                            .padding(.horizontal, horizontalPadding)
                    }
                    if let current = currentCombo {
                        ComboDetailCardView(cube: current)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalSpacing)
                            .onTapGesture {
                                showDetailPage = true
                            }
                    }
                    if let next = nextCombo {
                        ComboTopBottomPreview(cube: next)
                            .frame(height: previewHeight)
                            .padding(.horizontal, horizontalPadding)
                    }
                }
                .frame(maxHeight: .infinity)

                // 底部按鈕 + 選單
                ZStack(alignment: .bottomLeading) {

                    if showAddMenu {
                        VStack(alignment: .leading, spacing: 12) {
                            addMenuButton(title: "Combo", icon: "square.grid.2x2", type: .combo)
                            addMenuButton(title: "Timer", icon: "timer", type: .timer)
                            addMenuButton(title: "Countdown", icon: "clock.arrow.circlepath", type: .countdown)
                            addMenuButton(title: "Repetitions", icon: "repeat", type: .repetitions)
                        }
                        .padding(12)
                        .frame(width: UIScreen.main.bounds.width - horizontalPadding * 2)
                        .frame(maxHeight: addMenuMaxHeight)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        .padding(.bottom, 70)
                        .padding(.leading, horizontalPadding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(10)
                    }

                    HStack {
                        if isUnlocked {
                            Button {
                                withAnimation(.spring()) { showAddMenu.toggle() }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 16)
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
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 12)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { handleDragChanged($0) }
                    .onEnded { handleDragEnded($0) }
            )
            // ✅ CubeEditView 由選單觸發
            .sheet(isPresented: $showEdit) {
                if let cube = editingCube {
                    CubeEditView(cube: cube)
                }
            }
            .fullScreenCover(isPresented: $showDetailPage) {
                if let current = currentCombo {
                    ComboDetailFullPageView(cube: current)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: helpers
    var currentCombo: Cube? {
        guard !combos.isEmpty else { return nil }
        if currentIndex < 0 { currentIndex = 0 }
        if currentIndex >= combos.count { currentIndex = combos.count - 1 }
        return combos[currentIndex]
    }
    var previousCombo: Cube? { guard combos.indices.contains(currentIndex - 1) else { return nil }; return combos[currentIndex - 1] }
    var nextCombo: Cube? { guard combos.indices.contains(currentIndex + 1) else { return nil }; return combos[currentIndex + 1] }

    func goNext() { guard currentIndex < combos.count - 1 else { return }; withAnimation(.spring()) { currentIndex += 1 } }
    func goPrev() { guard currentIndex > 0 else { return }; withAnimation(.spring()) { currentIndex -= 1 } }

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

    @ViewBuilder
    func addMenuButton(title: String, icon: String, type: CubeActionType) -> some View {
        Button {
            let newCube = addNewItem(type: type)
            editingCube = newCube
            showEdit = true
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

    func addNewItem(type: CubeActionType) -> Cube {
        // 從模板找對應 Cube
        guard let templateCube = cubeTemplates.first(where: { $0.actionType == type }) else {
            // 找不到模板就返回一個預設 Cube
            return Cube(
                title: type.rawValue.capitalized,
                icon: "⚡️",
                backgroundColor: "#FFBF00",
                actionType: type,
                tags: []
            )
        }

        // 複製模板 Cube（不影響原本模板）
        let newCube = templateCube.makeCube()
        
        // 不直接寫入 SwiftData，等待編輯
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            currentIndex = max(0, combos.count - 1)
        }
        
        return newCube
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

    @Environment(\.modelContext) private var context

    // MARK: - 解析目前 Cube 自己的 Action 參數
    private var actionParams: [String: Any] {
        parseActionParameters(cube.actionParameters)
    }

    private var duration: Double {
        actionParams["duration"] as? Double ?? 0
    }

    private var loopCount: Int {
        actionParams["loopCount"] as? Int ?? 1
    }

    private var autoNextTask: Bool {
        actionParams["autoNextTask"] as? Bool ?? false
    }

    // MARK: - 子任務
    private var childCubes: [Cube] {
        cube.childrenIDs.compactMap { id in
            try? context.fetch(
                FetchDescriptor<Cube>(
                    predicate: #Predicate<Cube> { cube in
                        cube.id == id
                    }
                )
            ).first
        }
    }

    private var totalItems: Int { childCubes.count }

    private var totalTime: Double {
        childCubes
            .map { parseActionParameters($0.actionParameters)["duration"] as? Double ?? 0 }
            .reduce(0, +)
    }

    func parseActionParameters(_ data: Data?) -> [String: Any] {
        guard let data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {
            // ✅ Header
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
            }
            Divider()

            // ✅ 統計區
            HStack {
                Text("Items: \(totalItems)").font(.headline)
                Spacer()
                Text("Total: \(Int(totalTime / 60)) min").font(.headline)
            }
            .padding(.vertical, 4)
            Divider()

            // ✅ 子任務列表
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(childCubes, id: \.id) { child in
                        let params = parseActionParameters(child.actionParameters)
                        let childDuration = params["duration"] as? Double ?? 0

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
            Divider()

            // ✅ 操作按鈕
            HStack {
                Button("Edit") { onEdit() }
                Spacer()
                Button("Run") { onRun() }
            }
        }
        .padding()
        .background(Color(hex: cube.backgroundColor))
        .cornerRadius(16)
    }
}

struct ComboDetailFullPageView: View {
    let cube: Cube
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var tasks: [TaskItem] = []

    var body: some View {
        VStack(spacing: 16) {

            // ✅ Header
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
                Button("Close") { dismiss() }
            }
            .padding()

            Divider()

            // ✅ 統計
            let totalItems = tasks.count
            let totalTime = tasks.compactMap { $0.duration }.reduce(0, +)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Items: \(totalItems)").font(.headline)
                    Spacer()
                    Text("Total: \(Int(totalTime / 60)) min").font(.headline)
                }

                Divider()

                // ✅ 任務列表
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
                                        Text("\(Int(d / 60)) min")
                                            .foregroundColor(.secondary)
                                    }

                                case .inProgress:
                                    Text(timeString(from: task.remaining))
                                        .foregroundColor(.blue)

                                case .completed:
                                    Text("Done")
                                        .foregroundColor(.green)
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

            // ✅ 底部按鈕
            HStack {
                Button("Edit") {}
                    .buttonStyle(.bordered)

                Spacer()

                Button("Run All") {
                    for i in tasks.indices {
                        startTask(at: i)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: cube.backgroundColor).opacity(0.35))

        // ✅ ✅ ✅ 這裡是最重要的修正點
        .onAppear {
            tasks = cube.childrenIDs.compactMap { id in
                // 從 context 取出對應的子 Cube
                guard let childCube = try? context.fetch(
                    FetchDescriptor<Cube>(
                        predicate: #Predicate<Cube> { $0.id == id }
                    )
                ).first else { return nil }

                let params = parseActionParameters(childCube.actionParameters)
                let duration = params["duration"] as? Double

                return TaskItem(cube: childCube, duration: duration)
            }
        }
    }

    // ✅ 單一任務啟動 / 暫停 / 完成
    func startTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }

        var task = tasks[index]

        switch task.status {
        case .completed:
            return

        case .inProgress:
            task.status = .notStarted
            tasks[index] = task
            return

        case .notStarted:
            task.status = .inProgress
        }

        tasks[index] = task

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                guard tasks.indices.contains(index) else {
                    timer.invalidate()
                    return
                }

                var task = tasks[index]
                guard task.status == .inProgress else {
                    timer.invalidate()
                    return
                }

                if task.remaining > 0 {
                    task.remaining -= 1
                } else {
                    task.status = .completed
                    timer.invalidate()
                }

                tasks[index] = task
            }
        }
    }

    func parseActionParameters(_ data: Data?) -> [String: Any] {
        guard let data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    // ✅ 秒數轉 mm:ss
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

        // ---------------------------
        // MARK: - Helper to insert Cube
        // ---------------------------
        func insertCube(_ cube: Cube) {
            context.insert(cube)
        }

        // ---------------------------
        // MARK: - Combo 1
        // ---------------------------
        let warmup10s = Cube(
            title: "熱身 10 秒",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10)]
        )

        let hiit1min = Cube(
            title: "高強度間歇 1 分鐘",
            icon: "⚡️",
            backgroundColor: "#FF0000",
            actionType: .timer,
            tags: ["interval", "hiit"],
            actionParameters: ["duration": .double(60)]
        )

        insertCube(warmup10s)
        insertCube(hiit1min)

        let combo1 = Cube(
            title: "間歇訓練",
            icon: "⚡️",
            backgroundColor: "#FFBF00",
            actionType: .combo,
            tags: ["combo", "hiit"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo1.appendChild(warmup10s)
        combo1.appendChild(hiit1min)
        insertCube(combo1)

        // ---------------------------
        // MARK: - Combo 2
        // ---------------------------
        let warmup10min = Cube(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10.0*60.0)]
        )

        let climb6_10km = Cube(
            title: "爬坡 6–10km",
            icon: "⛰️",
            backgroundColor: "#00FF00",
            actionType: .timer,
            tags: ["climb", "strength"],
            actionParameters: ["duration": .double(20.0*60.0)]
        )

        insertCube(warmup10min)
        insertCube(climb6_10km)

        let combo2 = Cube(
            title: "爬坡肌耐力",
            icon: "⛰️",
            backgroundColor: "#919E71",
            actionType: .combo,
            tags: ["combo", "climb"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo2.appendChild(warmup10min)
        combo2.appendChild(climb6_10km)
        insertCube(combo2)

        // ---------------------------
        // MARK: - Combo 3
        // ---------------------------
        let warmup10min2 = Cube(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            tags: ["warmup", "easy"],
            actionParameters: ["duration": .double(10.0*60.0)]
        )

        let cadence95rpm = Cube(
            title: "踩踏節奏 95rpm",
            icon: "🎵",
            backgroundColor: "#0000FF",
            actionType: .timer,
            tags: ["cadence", "rhythm"],
            actionParameters: ["duration": .double(15.0*60.0)]
        )

        insertCube(warmup10min2)
        insertCube(cadence95rpm)

        let combo3 = Cube(
            title: "踩踏節奏提升",
            icon: "🎵",
            backgroundColor: "#CAC5DD",
            actionType: .combo,
            tags: ["combo", "cadence"],
            actionParameters: [
                "loopCount": .int(1),
                "autoNextTask": .bool(true)
            ]
        )

        combo3.appendChild(warmup10min2)
        combo3.appendChild(cadence95rpm)
        insertCube(combo3)

        // ---------------------------
        // MARK: - Dice Cube
        // ---------------------------
        let diceCube = Cube(
            title: "隨機訓練",
            icon: "🎲",
            backgroundColor: "#FF69B4",
            actionType: .dice,
            tags: ["dice"],
            actionParameters: [
                "possibleActions": .string("timer,countdown,repetitions")
            ]
        )

        insertCube(diceCube)

        // ---------------------------
        // MARK: - Finish
        // ---------------------------
        UserDefaults.standard.set(true, forKey: flagKey)
        print("🔥 Sample Cubes saved successfully!")

    } catch {
        print("❌ Failed to fetch or save sample cubes: \(error)")
    }
}
