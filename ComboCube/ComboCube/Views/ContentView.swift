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

    @Query(filter: #Predicate<Cube> { $0.actionType == "combo" },
           sort: [SortDescriptor(\Cube.title)])
    private var combos: [Cube]

    @State private var currentIndex: Int = 0
    @State private var showEdit: Bool = false
    @State private var showDetailPage: Bool = false

    @State private var dragDirectionLocked = false
    @State private var isVertical = false

    let topBottomHeight: CGFloat = 60
    let horizontalPadding: CGFloat = 20
    let verticalSpacing: CGFloat = 8

    var body: some View {
        NavigationStack {
            VStack(spacing: verticalSpacing) {

                // 上方 Combo Preview
                if let prev = previousCombo {
                    ComboTopBottomPreview(cube: prev)
                        .frame(height: topBottomHeight)
                        .padding(.horizontal, horizontalPadding)
                } else {
                    Spacer().frame(height: topBottomHeight + verticalSpacing)
                }

                // 中間 Combo Detail 填滿剩餘空間
                if let current = currentCombo {
                    ComboDetailCardView(
                        cube: current,
                        onRun: { showDetailPage = true },
                        onEdit: { showEdit = true }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalSpacing)
                    .contentShape(Rectangle())        // 讓整個區域可點擊
                    .onTapGesture {
                        showDetailPage = true
                    }
                }


                // 下方 Combo Preview
                if let next = nextCombo {
                    ComboTopBottomPreview(cube: next)
                        .frame(height: topBottomHeight)
                        .padding(.horizontal, horizontalPadding)
                } else {
                    Spacer().frame(height: topBottomHeight + verticalSpacing)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { handleDragChanged($0) }
                    .onEnded { handleDragEnded($0) }
            )
            .sheet(isPresented: $showEdit) {
                if let current = currentCombo {
                    CubeEditView(cube: current)
                }
            }
            .navigationTitle("Combos")
            .fullScreenCover(isPresented: $showDetailPage) {
                if let current = currentCombo {
                    ComboDetailFullPageView(cube: current)
                }
            }
        }
    }

    // MARK: - Helpers
    var currentCombo: Cube? {
        combos.indices.contains(currentIndex) ? combos[currentIndex] : nil
    }

    var previousCombo: Cube? {
        currentIndex > 0 ? combos[currentIndex - 1] : nil
    }

    var nextCombo: Cube? {
        currentIndex < combos.count - 1 ? combos[currentIndex + 1] : nil
    }

    func goNext() {
        guard currentIndex < combos.count - 1 else { return }
        withAnimation(.spring()) { currentIndex += 1 }
    }

    func goPrev() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring()) { currentIndex -= 1 }
    }

    func runCombo(_ combo: Cube) {
        print("Run → \(combo.title)")
    }

    // MARK: - Drag Handling
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
        } else {
            if value.translation.width < -80 { showEdit = true }
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
    let onRun: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Top 區域
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
            }
            Divider()
            
            // Detail 區域
            VStack(alignment: .leading, spacing: 12) {
                
                // 1️⃣ Summary 區：總數 + 總時間
                let totalItems = cube.children.count
                let totalTime = cube.children.compactMap { $0.duration }.reduce(0, +)
                
                HStack {
                    Text("Items: \(totalItems)")
                        .font(.headline)
                    Spacer()
                    Text("Total: \(Int(totalTime / 60)) min")
                        .font(.headline)
                }
                .padding(.vertical, 4)

                Divider()
                
                // 2️⃣ Items List 區
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(cube.children) { child in
                            HStack {
                                Text(child.icon)
                                Text(child.title)
                                Spacer()
                                if child.duration > 0 {
                                    Text("\(Int(child.duration / 60)) min")
                                        .foregroundColor(.secondary)
                                }                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }

            Divider()
            
            // Bottom Buttons
            HStack {
                Button("Edit") { onEdit() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Run") { onRun() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(hex: cube.backgroundColor)) // ⭐ 背景填滿
        .cornerRadius(16)
    }
}



// Task 狀態
enum TaskStatus {
    case notStarted, inProgress, completed
}

// 包裝 Cube 子任務狀態
struct TaskItem: Identifiable {
    let id: UUID
    let icon: String
    let title: String
    let duration: TimeInterval?
    
    var remaining: TimeInterval
    var status: TaskStatus
    
    init(cube: Cube) {
        self.id = cube.id
        self.icon = cube.icon
        self.title = cube.title
        self.duration = cube.duration
        self.remaining = cube.duration
        self.status = .notStarted
    }
}

struct ComboDetailFullPageView: View {
    let cube: Cube
    @Environment(\.dismiss) private var dismiss
    
    // 每個子任務狀態
    @State private var tasks: [TaskItem] = []
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Top: Icon + Title + Close
            HStack {
                Text(cube.icon).font(.largeTitle)
                Text(cube.title).font(.title).bold()
                Spacer()
                Button("Close") { dismiss() }
            }
            .padding()
            
            Divider()
            
            // Summary 區
            let totalItems = tasks.count
            let totalTime = tasks.compactMap { $0.duration }.reduce(0, +)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Items: \(totalItems)").font(.headline)
                    Spacer()
                    Text("Total: \(Int(totalTime / 60)) min").font(.headline)
                }
                
                Divider()
                
                // Items List 區
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(tasks.indices, id: \.self) { i in
                            let task = tasks[i]
                            HStack {
                                Text(task.icon)
                                Text(task.title)
                                Spacer()
                                
                                // 顯示剩餘時間或完成
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
                                    Text("Done").foregroundColor(.green)
                                }
                                
                                // Start/Pause 按鈕
                                Button(action: {
                                    startTask(at: i)
                                }) {
                                    Text(task.status == .inProgress ? "Pause" : "Start")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Bottom Buttons
            HStack {
                Button("Edit") {
                    // TODO: 編輯邏輯
                }
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
            tasks = cube.children.map { TaskItem(cube: $0) }
        }
    }
    
    // MARK: - Helpers
    func startTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }

        // 取出 task（避免 SwiftUI mutation error）
        var task = tasks[index]

        // 狀態切換 Start / Pause
        switch task.status {
        case .completed:
            return

        case .inProgress:
            task.status = .notStarted   // 暫停後回到待機
            tasks[index] = task
            return

        case .notStarted:
            task.status = .inProgress
        }

        // 寫回 task（開始計時狀態）
        tasks[index] = task

        // 啟動 Timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {

                // index 失效
                guard tasks.indices.contains(index) else {
                    timer.invalidate()
                    return
                }

                var task = tasks[index]

                // 如果離開 inProgress → 停止
                guard task.status == .inProgress else {
                    timer.invalidate()
                    return
                }

                // 倒數邏輯
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


    func timeString(from seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct CubeActionSettingsView: View {
    let action: CubeActionType
    @Binding var parameters: [CubeActionParameter]  // UI 專用
    var isEditable: Bool = false                     // 模式切換

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let template = cubeActionParameterDefinitions.first(where: { $0.type == action }) {
                ForEach(parameters.indices, id: \.self) { i in
                    let paramTemplate = template.parameters.first(where: { $0.name == parameters[i].name }) ?? template.parameters[i]
                    let value = parameters[i].type

                    HStack {
                        Text(paramTemplate.name).font(.headline)
                        Spacer()

                        if isEditable {
                            switch value {
                            case .toggle:
                                Toggle("", isOn: binding(for: i, as: Bool.self))
                            case .value:
                                Stepper("\(binding(for: i, as: Int.self).wrappedValue)", value: binding(for: i, as: Int.self))
                            case .text:
                                TextField("Value", text: binding(for: i, as: String.self))
                                    .textFieldStyle(.roundedBorder)
                            case .time:
                                Stepper("\(Int(binding(for: i, as: Double.self).wrappedValue)) sec",
                                        value: binding(for: i, as: Double.self),
                                        in: 0...999)
                            case .progress:
                                ProgressView(value: binding(for: i, as: Double.self).wrappedValue)
                                    .frame(width: 120)
                            }
                        } else {
                            Text(displayText(for: value))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("No parameters for this action")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    // MARK: - Helpers
    func displayText(for type: CubeActionParameterType) -> String {
        switch type {
        case .toggle(let boolVal): return boolVal ? "ON" : "OFF"
        case .value(let intVal): return "\(intVal)"
        case .text(let textVal): return textVal
        case .time(let timeVal): return "\(Int(timeVal)) sec"
        case .progress(let progressVal): return "\(Int(progressVal * 100))%"
        }
    }

    func binding<T>(for index: Int, as type: T.Type) -> Binding<T> {
        Binding(
            get: {
                switch parameters[index].type {
                case .toggle(let val as T): return val
                case .value(let val as T): return val
                case .text(let val as T): return val
                case .time(let val as T): return val
                case .progress(let val as T): return val
                default: fatalError("Type mismatch")
                }
            },
            set: { newValue in
                switch parameters[index].type {
                case .toggle: parameters[index].type = .toggle(newValue as! Bool)
                case .value: parameters[index].type = .value(newValue as! Int)
                case .text: parameters[index].type = .text(newValue as! String)
                case .time: parameters[index].type = .time(newValue as! Double)
                case .progress: parameters[index].type = .progress(newValue as! Double)
                }
            }
        )
    }
}




// 初始化 Sample Cubes，只在資料庫空的時候建立
@MainActor
func initializeSampleCubesIfNeeded(context: ModelContext) async {

    let flagKey = "didInitializeSampleCubes"

    // 若已匯入過 → 直接跳過
    if UserDefaults.standard.bool(forKey: flagKey) {
        return
    }

    do {
        // 若資料庫內已有資料 → 不匯入
        let cubes = try context.fetch(FetchDescriptor<Cube>())
        if !cubes.isEmpty {
            UserDefaults.standard.set(true, forKey: flagKey)
            return
        }

        // MARK: - Task Cubes
        let warmup = Cube(
            title: "熱身 10 分鐘",
            icon: "🔥",
            backgroundColor: "#FFA500",
            actionType: .timer,
            duration: 10 * 60,
            durationEn: true,
            durationProgressEn: true,
            tapCountEn: false,
            tags: ["warmup", "easy"],
            sourceURL: URL(string: "https://example.com/warmup.mp4")
        )

        let interval1 = Cube(
            title: "高強度間歇 1 分鐘",
            icon: "⚡️",
            backgroundColor: "#FF0000",
            actionType: .timer,
            duration: 60,
            durationEn: true,
            durationProgressEn: true,
            tags: ["interval", "hiit"],
            sourceURL: URL(string: "https://example.com/interval1.mp4")
        )

        let interval2 = Cube(
            title: "低強度騎乘 10 分鐘",
            icon: "💨",
            backgroundColor: "#FFFF00",
            actionType: .timer,
            duration: 10 * 60,
            durationEn: true,
            durationProgressEn: true,
            tags: ["low", "recovery"],
            sourceURL: URL(string: "https://example.com/interval2.mp4")
        )

        let climb = Cube(
            title: "爬坡 6-10km",
            icon: "⛰️",
            backgroundColor: "#00FF00",
            actionType: .timer,
            duration: 20 * 60,
            durationEn: true,
            durationProgressEn: true,
            tags: ["climb", "strength"],
            sourceURL: URL(string: "https://example.com/climb.mp4")
        )

        let cadence = Cube(
            title: "踩踏節奏 95rpm",
            icon: "🎵",
            backgroundColor: "#0000FF",
            actionType: .timer,
            duration: 15 * 60,
            durationEn: true,
            durationProgressEn: true,
            tags: ["cadence", "rhythm"],
            sourceURL: URL(string: "https://example.com/cadence.mp4")
        )

        // MARK: - Combo Cubes
        let combo1 = Cube(
            title: "間歇訓練",
            icon: "⚡️",
            backgroundColor: "#FFBF00",
            actionType: .combo,
            loopCount: 1,
            autoNextTask: true,
            tags: ["combo", "hiit"]
        )
        combo1.children.append(contentsOf: [warmup, interval1, interval2])

        let combo2 = Cube(
            title: "爬坡肌耐力",
            icon: "⛰️",
            backgroundColor: "#919E71",
            actionType: .combo,
            loopCount: 1,
            autoNextTask: true,
            tags: ["combo", "climb"]
        )
        combo2.children.append(contentsOf: [warmup, climb])

        let combo3 = Cube(
            title: "踩踏節奏提升",
            icon: "🎵",
            backgroundColor: "#CAC5DD",
            actionType: .combo,
            loopCount: 1,
            autoNextTask: true,
            tags: ["combo", "cadence"]
        )
        combo3.children.append(contentsOf: [warmup, cadence])

        // MARK: - Save all cubes
        let allCubes = [warmup, interval1, interval2, climb, cadence,
                        combo1, combo2, combo3]

        for cube in allCubes {
            context.insert(cube)
        }

        try context.save()
        print("🔥 Sample Cubes saved successfully!")

        UserDefaults.standard.set(true, forKey: flagKey)

    } catch {
        print("❌ Failed to fetch or save sample cubes: \(error)")
    }
}
