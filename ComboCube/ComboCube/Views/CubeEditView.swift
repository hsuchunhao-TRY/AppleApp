import SwiftUI

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
                    .onChange(of: selectedAction) { newValue, oldValue in
                        // newValue 是更新後的值
                        // oldValue 是更新前的值
                        if let template = cubeActionParameterDefinitions.first(where: { $0.type == newValue }) {
                            parameters = template.parameters.map {
                                CubeActionParameter(name: $0.name, type: $0.type, used: $0.used, isHidden: $0.isHidden)
                            }
                        } else {
                            parameters = []
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

                    // 把 UI 用的 parameters 寫回 Cube model
                    applyParametersToCube()

                    dismiss()
                }
            }
        }
        .onAppear {
            // 載入現有 cube
            icon = cube.icon
            title = cube.title
            selectedAction = cube.type
            backgroundColor = Color(hex: cube.backgroundColor)

            if let template = cubeActionParameterDefinitions.first(where: { $0.type == selectedAction }) {
                // 初始化 parameters
                parameters = template.parameters.map {
                    // 盡量把 cube 內已有值對應回 UI
                    var param = CubeActionParameter(name: $0.name, type: $0.type, used: $0.used, isHidden: $0.isHidden)
                    switch param.name {
                    case "Duration":
                        param.type = .time(cube.duration)
//                    case "Repetition Count":
//                        if let value = cube.repetitions {
//                            param.type = .value(value)
//                        }
//                    case "Enable Sound":
//                        param.type = .toggle(cube.enableSound)
                    default:
                        break
                    }
                    return param
                }
            }
        }
    }

    // MARK: - Helpers
    private func applyParametersToCube() {
        for param in parameters {
            switch param.name {
            case "Duration":
                if case .time(let value) = param.type {
                    cube.duration = value
                }
//            case "Repetition Count":
//                if case .value(let value) = param.type {
//                    cube.repetitions = value
//                }
//            case "Enable Sound":
//                if case .toggle(let value) = param.type {
//                    cube.enableSound = value
//                }
            default:
                break
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
