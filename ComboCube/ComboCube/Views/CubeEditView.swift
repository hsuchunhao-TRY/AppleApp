import SwiftUI

// MARK: - CubeEditView
struct CubeEditView: View {
    @Environment(\.dismiss) var dismiss

    @State private var cube: Cube
    @State private var selectedAction: CubeActionType
    @State private var parameters: [CubeActionParameter] = []

    // 上半部資料
    @State private var icon: String
    @State private var title: String
    @State private var selectedTags: [String]
    @State private var notes: String
    @State private var backgroundColor: Color

    // 預設選項
    private let availableIcons = [
        "flame.fill", "bolt.fill", "star.fill", "timer", "clock.fill",
        "bicycle", "figure.walk", "figure.yoga", "book.fill", "pencil", "sun.max.fill", "moon.fill"
    ]
    private let availableTags = ["Workout", "Study", "Focus", "Fun"]
    private let backgroundOptions: [Color] = [.yellow, .orange, .blue, .green, .pink]

    var body: some View {
        VStack(spacing: 0) {
            // 上半部 Cube 資訊卡
            VStack(spacing: 12) {

                // 左上 tags
                HStack {
                    Text(selectedTags.isEmpty ? "" : selectedTags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                // 中央 icon + title + notes + 背景色選擇
                VStack(spacing: 16) {
                    // Icon 選擇
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { name in
                                Button {
                                    icon = name
                                } label: {
                                    Image(systemName: name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30) // 跟背景色圓形大小一致
                                        .padding(6)
                                        .background(icon == name ? Color.white.opacity(0.3) : Color.clear)
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }

                    // Title
                    TextField("Title", text: $title)
                        .font(.title)
                        .multilineTextAlignment(.center)

                    // Notes
                    VStack(spacing: 4) {
                        TextField("Notes", text: Binding(
                            get: { notes },
                            set: { newValue in
                                if newValue.count <= 20 {
                                    notes = newValue
                                } else {
                                    // 超過 20 字，保留前 20 個
                                    notes = String(newValue.prefix(20))
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.footnote)

                        if notes.count >= 20 {
                            Text("最多20字")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }


                    // 背景色選擇 Button
                    HStack(spacing: 12) {
                        ForEach(backgroundOptions, id: \.self) { color in
                            Button(action: { backgroundColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: backgroundColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                }

                Spacer()

                // 左下 action type + 右下 updatedAt
                HStack {
                    Text(cube.type.rawValue.capitalized)
                        .font(.caption)
                        .bold()

                    Spacer()

                    Text(cube.updatedAt.formatted(.dateTime.year().month().day()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxHeight: .infinity)
            .padding()
            .background(backgroundColor)

            Divider()

            // 下半部 Form：Parameters + Tags + Save
            Form {
                if let template = cubeTemplates.first(where: { $0.actionType == cube.type }),
                   let actionParams = template.defaultParameters {
                    Section {
                        CubeActionSettingsView(
                            action: cube.type,
                            parameters: $parameters,
                            isEditable: true
                        )
                        .background(backgroundColor.opacity(0.3))
                        .onAppear {
                            parameters = actionParams.map { key, value in
                                let type: CubeActionParameterType
                                switch value {
                                case .int(let v): type = .value(v)
                                case .double(let v): type = .time(v)
                                case .bool(let v): type = .toggle(v)
                                case .string(let v): type = .text(v)
                                }
                                return CubeActionParameter(name: key, type: type, used: true, isHidden: false)
                            }
                        }
                    }
                }




                // Save Button
                Button("Save") {
                    cube.title = title
                    cube.icon = icon
                    cube.type = selectedAction
                    cube.tags = selectedTags
                    cube.notes = notes
                    cube.backgroundColor = backgroundColor.toHex() ?? "#FFBF00"
                    applyParametersToCube()
                    dismiss()
                }
            }
            .scrollContentBackground(.hidden) // 隱藏 Form 系統背景
            // 整個 Form 背景較亮
            .background(backgroundColor.opacity(0.3))
            .onAppear {
                icon = cube.icon
                title = cube.title
                selectedAction = cube.type
                selectedTags = cube.tags
                notes = cube.notes ?? ""
                backgroundColor = Color(hex: cube.backgroundColor)
                loadParameters(for: selectedAction)
            }
        }
    }

    // MARK: - Helpers
    private func loadParameters(for actionType: CubeActionType) {
        guard let data = cube.actionParameters else {
            parameters = []
            return
        }

        do {
            let parametersDict = try JSONDecoder().decode([String: CodableValue].self, from: data)
            parameters = parametersDict.map { key, value in
                let type: CubeActionParameterType
                switch value {
                case .int(let v): type = .value(v)
                case .double(let v): type = .time(v)
                case .bool(let v): type = .toggle(v)
                case .string(let v): type = .text(v)
                }
                return CubeActionParameter(name: key, type: type, used: true, isHidden: false)
            }
        } catch {
            print("❌ Failed to decode actionParameters: \(error)")
            parameters = []
        }
    }

    private func applyParametersToCube() {
        var updatedDict: [String: CodableValue] = [:]

        // 將 CubeActionParameter 轉回 CodableValue
        for param in parameters {
            switch param.type {
            case .value(let v): updatedDict[param.name] = .int(v)
            case .time(let v): updatedDict[param.name] = .double(v)
            case .toggle(let v): updatedDict[param.name] = .bool(v)
            case .text(let v): updatedDict[param.name] = .string(v)
            case .progress(let v): updatedDict[param.name] = .double(v)
            }
        }

        do {
            let data = try JSONEncoder().encode(updatedDict)
            cube.actionParameters = data
        } catch {
            print("❌ Failed to encode actionParameters: \(error)")
        }
    }
    
    // MARK: - Init
    init(cube: Cube) {
        _cube = State(initialValue: cube)
        _selectedAction = State(initialValue: cube.type)
        _icon = State(initialValue: cube.icon)
        _title = State(initialValue: cube.title)
        _selectedTags = State(initialValue: cube.tags)
        _notes = State(initialValue: cube.notes ?? "")
        _backgroundColor = State(initialValue: Color(hex: cube.backgroundColor))
    }
}

// MARK: - CubeActionSettingsView
struct CubeActionSettingsView: View {
    let action: CubeActionType
    @Binding var parameters: [CubeActionParameter]
    var isEditable: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if parameters.isEmpty {
                Text("No parameters for this action")
                    .foregroundColor(.gray)
            } else {
                ForEach($parameters, id: \.name) { $param in
                    HStack {
                        Text(param.name).font(.headline)
                        Spacer()
                        if isEditable {
                            switch param.type {
                            case .toggle:
                                Toggle("", isOn: Binding(
                                    get: { param.type.valueAsBool() },
                                    set: { param.type = .toggle($0) }
                                ))
                            case .value:
                                Stepper("\(param.type.valueAsInt())", value: Binding(
                                    get: { param.type.valueAsInt() },
                                    set: { param.type = .value($0) }
                                ))
                            case .text:
                                TextField("Value", text: Binding(
                                    get: { param.type.valueAsString() },
                                    set: { param.type = .text($0) }
                                ))
                                .textFieldStyle(.roundedBorder)
                            case .time:
                                Stepper("\(Int(param.type.valueAsDouble())) sec",
                                        value: Binding(
                                            get: { param.type.valueAsDouble() },
                                            set: { param.type = .time($0) }
                                        ),
                                        in: 0...999)
                            case .progress:
                                ProgressView(value: param.type.valueAsDouble())
                                    .frame(width: 120)
                            }
                        } else {
                            Text(param.type.displayText())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - CubeActionParameterType Helpers
extension CubeActionParameterType {
    func valueAsInt() -> Int {
        if case .value(let v) = self { return v }
        return 0
    }
    func valueAsDouble() -> Double {
        switch self {
        case .time(let v): return v
        case .progress(let v): return v
        default: return 0
        }
    }
    func valueAsString() -> String {
        if case .text(let v) = self { return v }
        return ""
    }
    func valueAsBool() -> Bool {
        if case .toggle(let v) = self { return v }
        return false
    }
    func displayText() -> String {
        switch self {
        case .toggle(let v): return v ? "ON" : "OFF"
        case .value(let v): return "\(v)"
        case .text(let v): return v
        case .time(let v): return "\(Int(v)) sec"
        case .progress(let v): return "\(Int(v*100))%"
        }
    }
}
