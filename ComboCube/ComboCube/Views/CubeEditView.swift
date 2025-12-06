import SwiftUI

// MARK: - CubeEditView
struct CubeEditView: View {
    @Environment(\.dismiss) var dismiss

    @State private var cube: Cube
    @State private var selectedAction: CubeActionType
    @State private var parameters: [CubeActionParameter] = []

    @State private var icon: String
    @State private var title: String
    @State private var backgroundColor: Color

    var body: some View {
        VStack(spacing: 0) {
            // 上半部：Icon + Title + 背景色
            VStack(spacing: 16) {
                TextField("Icon", text: $icon)
                    .font(.system(size: 60))
                    .multilineTextAlignment(.center)

                TextField("Title", text: $title)
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity)
            .padding()
            .background(backgroundColor)

            Divider()

            // 下半部：Action 設定
            Form {
                Section(header: Text("Action Type")) {
                    Picker("Action Type", selection: $selectedAction) {
                        Text("Combo").tag(CubeActionType.combo)
                        Text("Timer").tag(CubeActionType.timer)
                        Text("Countdown").tag(CubeActionType.countdown)
                        Text("Repetitions").tag(CubeActionType.repetitions)
                        Text("None").tag(CubeActionType.none)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedAction) { newValue in
                        // 延遲更新 parameters 避免 SwiftUI crash
                        DispatchQueue.main.async {
                            if let template = cubeActionParameterDefinitions.first(where: { $0.type == newValue }) {
                                parameters = template.parameters.map { paramTemplate in
                                    var param = CubeActionParameter(
                                        name: paramTemplate.name,
                                        type: paramTemplate.type,
                                        used: paramTemplate.used,
                                        isHidden: paramTemplate.isHidden
                                    )
                                    // 對應 cube 現有值
                                    switch param.name {
                                    case "Duration":
                                        param.type = .time(cube.duration)
                                    case "Enable Sound":
                                        param.type = .toggle(cube.soundEn)
                                    case "Progress":
                                        param.type = .progress(cube.durationProgressEn ? 1.0 : 0.0)
                                    case "Tap Count":
                                        param.type = .value(cube.tapCount)
                                    case "Tap Enable":
                                        param.type = .toggle(cube.tapCountEn)
                                    default:
                                        break
                                    }
                                    return param
                                }
                            } else {
                                parameters = []
                            }
                        }
                    }
                }

                if !parameters.isEmpty {
                    Section(header: Text("Parameters")) {
                        CubeActionSettingsView(action: selectedAction, parameters: $parameters, isEditable: true)
                    }
                }

                Button("Save") {
                    cube.title = title
                    cube.icon = icon
                    cube.type = selectedAction
                    applyParametersToCube()
                    dismiss()
                }
            }
            .onAppear {
                loadParametersFromCube()
            }
        }
        .onAppear {
            icon = cube.icon
            title = cube.title
            selectedAction = cube.type
            backgroundColor = Color(hex: cube.backgroundColor)
            // 初始化 parameters
            DispatchQueue.main.async {
                if let template = cubeActionParameterDefinitions.first(where: { $0.type == selectedAction }) {
                    parameters = template.parameters.map { paramTemplate in
                        var param = CubeActionParameter(
                            name: paramTemplate.name,
                            type: paramTemplate.type,
                            used: paramTemplate.used,
                            isHidden: paramTemplate.isHidden
                        )
                        switch param.name {
                        case "Duration":
                            param.type = .time(cube.duration)
                        case "Enable Sound":
                            param.type = .toggle(cube.soundEn)
                        case "Progress":
                            param.type = .progress(cube.durationProgressEn ? 1.0 : 0.0)
                        case "Tap Count":
                            param.type = .value(cube.tapCount)
                        case "Tap Enable":
                            param.type = .toggle(cube.tapCountEn)
                        default:
                            break
                        }
                        return param
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    enum CubeParameterName: String {
        // Timer
        case duration = "Duration"
        case enableSound = "Enable Sound"
        case progress = "Progress"

        // Tap
        case tapCount = "Tap Count"
        case tapEnable = "Tap Enable"
        case tapProgress = "Tap Progress"

        // Combo
        case loopCount = "Loop Count"
        case autoNextTask = "Auto Next Task"
    }

    private func loadParametersFromCube() {
        guard let template = cubeActionParameterDefinitions
            .first(where: { $0.type == cube.type }) else {
            parameters = []
            return
        }

        parameters = template.parameters.map { templateParam in
            var param = templateParam

            if let name = CubeParameterName(rawValue: templateParam.name) {
                switch name {
                case .duration:
                    param.type = .time(cube.duration)
                case .enableSound:
                    param.type = .toggle(cube.soundEn)
                case .progress:
                    param.type = .progress(cube.durationProgressEn ? 1.0 : 0.0)
                case .tapCount:
                    param.type = .value(cube.tapCount)
                case .tapEnable:
                    param.type = .toggle(cube.tapCountEn)
                case .tapProgress:
                    param.type = .progress(cube.tapCountProgressEn ? 1.0 : 0.0)
                case .loopCount:
                    param.type = .value(cube.loopCount ?? 0)
                case .autoNextTask:
                    param.type = .toggle(cube.autoNextTask)
                }
            }

            return param
        }
    }

    private func applyParametersToCube() {
        for param in parameters {
            guard let name = CubeParameterName(rawValue: param.name) else { continue }

            switch name {

            // MARK: - Timer
            case .duration:
                if case .time(let value) = param.type {
                    cube.duration = value
                }

            case .enableSound:
                if case .toggle(let value) = param.type {
                    cube.soundEn = value
                }

            case .progress:
                if case .progress(let value) = param.type {
                    cube.durationProgressEn = value > 0
                }

            // MARK: - Tap Count
            case .tapCount:
                if case .value(let value) = param.type {
                    cube.tapCount = value
                }

            case .tapEnable:
                if case .toggle(let value) = param.type {
                    cube.tapCountEn = value
                }

            case .tapProgress:
                if case .progress(let value) = param.type {
                    cube.tapCountProgressEn = value > 0
                }

            // MARK: - Combo
            case .loopCount:
                if case .value(let value) = param.type {
                    cube.loopCount = value
                }

            case .autoNextTask:
                if case .toggle(let value) = param.type {
                    cube.autoNextTask = value
                }
            }
        }
    }

    init(cube: Cube) {
        _cube = State(initialValue: cube)
        _selectedAction = State(initialValue: cube.type)
        _icon = State(initialValue: cube.icon)
        _title = State(initialValue: cube.title)
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
