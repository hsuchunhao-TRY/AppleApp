import SwiftUI

struct CubeEditView: View {
    @Environment(\.dismiss) var dismiss

    @State private var cube: Cube
    @State private var selectedAction: CubeActionType
    @State private var duration: TimeInterval
    @State private var repetitions: Int
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
            .background(backgroundColor)     // 淺橘色背景


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
                }

                if selectedAction == .timer || selectedAction == .countdown {
                    Section(header: Text("Duration (seconds)")) {
                        TextField("Duration", value: $duration, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                if selectedAction == .repetitions {
                    Section(header: Text("Repetitions")) {
                        TextField("Repetitions", value: $repetitions, format: .number)
                            .keyboardType(.numberPad)
                    }
                }

                Button("Save") {
                    cube.title = title
                    cube.icon = icon
                    cube.type = selectedAction
                    cube.duration = duration
                    cube.repetitions = repetitions
//                    cube.backgroundColor = Color(hex: "#FFDD99").toHex() ?? "#FFFFFF"
                    dismiss()
                }
            }
        }
        .onAppear {
            // 載入現有 cube
            icon = cube.icon
            title = cube.title
            selectedAction = cube.type
            duration = cube.duration ?? 0
            repetitions = cube.repetitions ?? 0
            backgroundColor = Color(hex: cube.backgroundColor)
        }
    }

    init(cube: Cube) {
        _cube = State(initialValue: cube)
        _selectedAction = State(initialValue: cube.type)
        _duration = State(initialValue: cube.duration ?? 0)
        _repetitions = State(initialValue: cube.repetitions ?? 0)
        _icon = State(initialValue: cube.icon)
        _title = State(initialValue: cube.title)
        _backgroundColor = State(initialValue: Color(hex: cube.backgroundColor))
    }
}
