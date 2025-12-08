//import SwiftUI
//import SwiftData
//
//enum CubeStyle {
//    case basic
//    case compact
//    case detailed
//    case large
//}
//
//struct CubeStyleView: View {
//
//    @Environment(\.modelContext) private var context
//
//    let cube: Cube
//    let style: CubeStyle
//
//    var body: some View {
//        switch style {
//        case .basic:
//            basicStyle
//        case .compact:
//            compactStyle
//        case .detailed:
//            detailedStyle
//        case .large:
//            largeStyle
//        }
//    }
//}
//
//private extension CubeStyleView {
//    
//    // MARK: - Helpers to get duration from CubeAction
//    var duration: Double {
//        cube.actions.first { $0.type == .timer || $0.type == .countdown }?
//            .parameters?["Duration"]?.valueAsDouble() ?? 0
//    }
//    
//    var basicStyle: some View {
//        VStack(spacing: 8) {
//            Text(cube.icon)
//                .font(.largeTitle)
//
//            Text(cube.title)
//                .font(.headline)
//                .multilineTextAlignment(.center)
//
//            if let notes = cube.notes {
//                Text(notes)
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//
//            if cube.type == .combo {
//                Text("\(cube.children.count) 項目")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            if duration > 0 {
//                Text("\(Int(duration / 60)) 分鐘")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, minHeight: 120)
//        .background(Color(hex: cube.backgroundColor))
//        .cornerRadius(12)
//        .shadow(radius: 2)
//    }
//
//    var compactStyle: some View {
//        HStack {
//            Text(cube.icon)
//                .font(.title2)
//
//            Text(cube.title)
//                .font(.subheadline)
//                .lineLimit(1)
//
//            Spacer()
//        }
//        .padding(10)
//        .background(Color(hex: cube.backgroundColor).opacity(0.6))
//        .cornerRadius(10)
//    }
//
//    var detailedStyle: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                Text(cube.icon)
//                    .font(.largeTitle)
//                Text(cube.title)
//                    .font(.title3)
//            }
//
//            if let notes = cube.notes {
//                Text(notes)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            if duration > 0 {
//                Text("時長：\(Int(duration / 60)) 分鐘")
//                    .font(.caption)
//            }
//
//            if cube.type == .combo {
//                Text("包含：\(cube.children.count) 個子項目")
//                    .font(.caption2)
//            }
//        }
//        .padding()
//        .background(Color(hex: cube.backgroundColor).opacity(0.9))
//        .cornerRadius(14)
//        .shadow(radius: 3)
//    }
//
//    var largeStyle: some View {
//        VStack(spacing: 12) {
//            Text(cube.icon)
//                .font(.system(size: 60))
//
//            Text(cube.title)
//                .font(.system(size: 28, weight: .bold))
//
//            if duration > 0 {
//                Text("\(Int(duration / 60)) 分鐘")
//                    .font(.headline)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding(30)
//        .frame(maxWidth: .infinity, minHeight: 160)
//        .background(Color(hex: cube.backgroundColor))
//        .cornerRadius(20)
//        .shadow(radius: 4)
//    }
//}
//
//// MARK: - CodableValue Helper
//private extension CodableValue {
//    func valueAsDouble() -> Double {
//        switch self {
//        case .int(let v): return Double(v)
//        case .double(let v): return v
//        case .string(let v): return Double(v) ?? 0
//        case .bool: return 0
//        }
//    }
//}
