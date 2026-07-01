import SwiftUI

struct GlassBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.99, blue: 1.0),
                Color(red: 1.0, green: 0.97, blue: 0.94),
                Color(red: 0.96, green: 0.96, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.48), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }
}

extension CareCategory {
    var tintColor: Color {
        Color(hex: tintHex)
    }
}

extension CareEntry {
    var tintColor: Color {
        Color(hex: tintHex)
    }
}

extension Color {
    init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
