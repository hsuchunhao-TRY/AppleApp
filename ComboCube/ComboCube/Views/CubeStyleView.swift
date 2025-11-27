import SwiftUI

enum CubeStyle {
    case basic      // 目前使用中的樣式
    case compact    // 小卡片
    case detailed   // 含更多資訊
    case large      // 大字版
    // 你之後可以新增更多…
}

struct CubeStyleView: View {
    let cube: Cube
    let style: CubeStyle

    var body: some View {
        switch style {
        case .basic:
            basicStyle

        case .compact:
            compactStyle

        case .detailed:
            detailedStyle

        case .large:
            largeStyle
        }
    }
}

private extension CubeStyleView {
    var basicStyle: some View {
        VStack(spacing: 8) {
            Text(cube.icon)
                .font(.largeTitle)

            Text(cube.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let notes = cube.notes {
                Text(notes)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if cube.actionType == "combo" {
                Text("\(cube.children.count) 項目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let duration = cube.duration {
                Text("\(Int(duration/60)) 分鐘")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(cube.backgroundColor))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

private extension CubeStyleView {
    var compactStyle: some View {
        HStack {
            Text(cube.icon)
                .font(.title2)

            Text(cube.title)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()
        }
        .padding(10)
        .background(Color(cube.backgroundColor).opacity(0.6))
        .cornerRadius(10)
    }
}

private extension CubeStyleView {
    var detailedStyle: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(cube.icon)
                    .font(.largeTitle)
                Text(cube.title)
                    .font(.title3)
            }

            if let notes = cube.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let duration = cube.duration {
                Text("時長：\(Int(duration / 60)) 分鐘")
                    .font(.caption)
            }

            if cube.actionType == "combo" {
                Text("包含：\(cube.children.count) 個子項目")
                    .font(.caption2)
            }
        }
        .padding()
        .background(Color(cube.backgroundColor).opacity(0.9))
        .cornerRadius(14)
        .shadow(radius: 3)
    }
}

private extension CubeStyleView {
    var largeStyle: some View {
        VStack(spacing: 12) {
            Text(cube.icon)
                .font(.system(size: 60))

            Text(cube.title)
                .font(.system(size: 28, weight: .bold))

            if let duration = cube.duration {
                Text("\(Int(duration/60)) 分鐘")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(Color(cube.backgroundColor))
        .cornerRadius(20)
        .shadow(radius: 4)
    }
}
