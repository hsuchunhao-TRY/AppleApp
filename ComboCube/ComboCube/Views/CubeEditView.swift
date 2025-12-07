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
                    .onChange(of: selectedAction) {oldValue, newValue in
                        loadParameters(for: newValue)
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
                icon = cube.icon
                title = cube.title
                selectedAction = cube.type
                backgroundColor = Color(hex: cube.backgroundColor)
                loadParameters(for: selectedAction)
            }
        }
    }

    // MARK: - Helpers
    private func loadParameters(for actionType: CubeActionType) {
        if let action = cube.actions.first(where: { $0.type == actionType }),
           let parametersDict = action.parameters {
            parameters = parametersDict.map { pair in
                let key = pair.key
                let value = pair.value
                let type: CubeActionParameterType
                switch value {
                case .int(let v): type = .value(v)
                case .double(let v): type = .time(v)
                case .bool(let v): type = .toggle(v)
                case .string(let v): type = .text(v)
                }
                return CubeActionParameter(name: key, type: type, used: true, isHidden: false)
            }
        } else {
            parameters = []
        }
    }

    private func applyParametersToCube() {
        for param in parameters {
            let key = param.name

            if let index = cube.actions.firstIndex(where: { $0.type == selectedAction }) {
                let action = cube.actions[index]
                var dict = action.parameters ?? [:]

                switch param.type {
                case .value(let v): dict[key] = .int(v)
                case .time(let v): dict[key] = .double(v)
                case .toggle(let v): dict[key] = .bool(v)
                case .text(let v): dict[key] = .string(v)
                case .progress(let v): dict[key] = .double(v) // 如果你 progress 需要存 double
                }

                action.parameters = dict
                cube.actions[index] = action
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
