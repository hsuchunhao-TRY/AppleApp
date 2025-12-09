import SwiftUI
import SwiftData

// MARK: - CubeActionParameterType
enum CubeActionParameterType {
    case toggle(Bool)
    case text(String)
    case time(Double)
    case value(Int)
    case progress(Double)
}

// MARK: - CubeActionParameter
struct CubeActionParameter: Identifiable {
    let id = UUID()
    let name: String
    var type: CubeActionParameterType
    let used: Bool
    let isHidden: Bool
}

// MARK: - Data Extension
extension Data {
    func toDict() -> [String: CodableValue]? {
        try? JSONDecoder().decode([String: CodableValue].self, from: self)
    }
}

struct CubeEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    // 編輯或新增
    @State private var cube: Cube
    private let isNew: Bool

    // 上半部資料
    @State private var icon: String
    @State private var title: String
    @State private var selectedTags: [String]
    @State private var notes: String
    @State private var backgroundColor: Color
    @State private var selectedAction: CubeActionType
    @State private var parameters: [CubeActionParameter] = []

    // UI 選項
    private let availableIcons = ["flame.fill","bolt.fill","star.fill","timer","clock.fill",
                                  "bicycle","figure.walk","figure.yoga","book.fill","pencil",
                                  "sun.max.fill","moon.fill"]
    private let backgroundOptions: [Color] = [.yellow, .orange, .blue, .green, .pink]

    // MARK: - Init
    init(cube: Cube? = nil, template: CubeTemplate? = nil) {
        if let cube = cube {
            _cube = State(initialValue: cube)
            _icon = State(initialValue: cube.icon)
            _title = State(initialValue: cube.title)
            _selectedTags = State(initialValue: cube.tags)
            _notes = State(initialValue: cube.notes ?? "")
            _backgroundColor = State(initialValue: Color(hex: cube.backgroundColor))
            _selectedAction = State(initialValue: cube.type)
            self.isNew = false
        } else if let template = template {
            let newCube = template.makeCube()
            _cube = State(initialValue: newCube)
            _icon = State(initialValue: template.icon)
            _title = State(initialValue: template.title)
            _selectedTags = State(initialValue: template.tags)
            _notes = State(initialValue: template.notes ?? "")
            _backgroundColor = State(initialValue: Color(hex: template.backgroundColor))
            _selectedAction = State(initialValue: template.actionType)
            self.isNew = true
        } else {
            fatalError("CubeEditView requires either a Cube or a CubeTemplate")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 上半部 Cube 資訊卡
            VStack(spacing: 12) {
                HStack {
                    Text(selectedTags.isEmpty ? "" : selectedTags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                VStack(spacing: 16) {
                    // Icon 選擇
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CubeUIManager.icons, id: \.self) { name in
                                Button { icon = name } label: {
                                    Image(systemName: name)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
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
                        TextField("最多20字", text: Binding(
                            get: { notes },
                            set: { notes = String($0.prefix(20)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.footnote)

                        // 顯示字數
                        Text("\(notes.count)/20")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // 背景色選擇
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CubeUIManager.colors, id: \.self) { color in
                                Button { backgroundColor = color } label: {
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
                        .padding(.horizontal)
                    }
                }

                Spacer()

                HStack {
                    Text(selectedAction.rawValue.capitalized)
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

            // 下半部 Form
            Form {
                CubeActionSettingsView(
                    action: selectedAction,
                    parameters: $parameters,
                    isEditable: true
                )
                .background(backgroundColor.opacity(0.3))

                Button("Save") {
                    saveCube()
                    dismiss()
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundColor.opacity(0.3))
            .onAppear {
                loadParameters()
            }
        }
    }

    // MARK: - Helpers
    private func loadParameters() {
        guard let data = cube.actionParameters else { parameters = []; return }
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
        for param in parameters {
            switch param.type {
            case .value(let v): updatedDict[param.name] = .int(v)
            case .time(let v): updatedDict[param.name] = .double(v)
            case .toggle(let v): updatedDict[param.name] = .bool(v)
            case .text(let v): updatedDict[param.name] = .string(v)
            case .progress(let v): updatedDict[param.name] = .double(v)
            }
        }
        do { cube.actionParameters = try JSONEncoder().encode(updatedDict) } catch { print(error) }
    }

    private func saveCube() {
        cube.title = title
        cube.icon = icon
        cube.type = selectedAction
        cube.tags = selectedTags
        cube.notes = notes
        cube.backgroundColor = backgroundColor.toHex() ?? "#FFBF00"
        applyParametersToCube()

        if isNew {
            context.insert(cube)
        }
        try? context.save()
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
        case .time(let v), .progress(let v): return v
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

// MARK: - CodableValue Helpers
extension CodableValue {
    func toCubeParameterType() -> CubeActionParameterType {
        switch self {
        case .bool(let v): return .toggle(v)
        case .int(let v): return .value(v)
        case .double(let v): return .time(v)
        case .string(let v): return .text(v)
        }
    }
}

// MARK: - Binding Helpers
extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith defaultValue: String) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
