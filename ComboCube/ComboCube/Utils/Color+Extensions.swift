import SwiftUI

extension Color {

    // MARK: - Initialize with HEX (#RRGGBB or #RRGGBBAA)
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let r, g, b, a: Double

        switch hexString.count {
        case 6: // RRGGBB
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
            a = 1.0

        case 8: // RRGGBBAA
            r = Double((int >> 24) & 0xFF) / 255
            g = Double((int >> 16) & 0xFF) / 255
            b = Double((int >> 8) & 0xFF) / 255
            a = Double(int & 0xFF) / 255

        default:
            r = 1; g = 1; b = 1; a = 1 // fallback → white
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    // MARK: - Named Color (fallback to white)
    init(name: String) {
        switch name.lowercased() {
        case "red": self = .red
        case "green": self = .green
        case "blue": self = .blue
        case "yellow": self = .yellow
        case "orange": self = .orange
        case "purple": self = .purple
        case "gray": self = .gray
        default: self = .white
        }
    }

    // MARK: - Safe Auto Parser (no conflict with SwiftUI)
    init(auto string: String) {
        if string.hasPrefix("#") {
            self.init(hex: string)
        } else {
            self.init(name: string)
        }
    }

    // MARK: - Convert Color → HEX for saving
    func toHex(includeAlpha: Bool = false) -> String? {
        let uiColor = UIColor(self)

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        if includeAlpha {
            return String(
                format: "#%02X%02X%02X%02X",
                Int(r*255), Int(g*255), Int(b*255), Int(a*255)
            )
        } else {
            return String(
                format: "#%02X%02X%02X",
                Int(r*255), Int(g*255), Int(b*255)
            )
        }
    }
}
