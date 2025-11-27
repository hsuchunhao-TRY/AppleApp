import SwiftUI

extension Color {
    // MARK: - HEX string
    init(hex: String) {
        self.init(hex: hex, opacity: 1.0)
    }
    
    init(hex: String, opacity: Double) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        
        let r, g, b: UInt64
        switch hexString.count {
        case 6:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        default:
            r = 255; g = 255; b = 255
        }
        
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: opacity)
    }
    
    // MARK: - Integer RGB 0-255
    init(r: Int, g: Int, b: Int) { self.init(r: r, g: g, b: b, a: 1.0) }
    init(r: Int, g: Int, b: Int, a: Double) {
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: a)
    }
    
    // MARK: - Double RGB 0.0-1.0
    init(r: Double, g: Double, b: Double) { self.init(r: r, g: g, b: b, a: 1.0) }
    init(r: Double, g: Double, b: Double, a: Double) { self.init(red: r, green: g, blue: b, opacity: a) }
    
    // MARK: - Name based
    init(name: String) {
        switch name.lowercased() {
        case "red": self.init(r: 255, g: 0, b: 0)
        case "green": self.init(r: 0, g: 128, b: 0)
        case "blue": self.init(r: 0, g: 0, b: 255)
        case "yellow": self.init(r: 255, g: 255, b: 0)
        case "orange": self.init(r: 255, g: 165, b: 0)
        case "purple": self.init(r: 128, g: 0, b: 128)
        case "gray": self.init(r: 128, g: 128, b: 128)
        default: self.init(r: 255, g: 255, b: 255) // 白色預設
        }
    }

    // 自動判斷 HEX 或名稱
    init(_ string: String) {
        if string.hasPrefix("#") {
            self.init(hex: string)
        } else {
            self.init(name: string)
        }
    }
}
