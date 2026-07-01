import SwiftUI

struct CareCategorySymbolView: View {
    let category: CareCategory

    var body: some View {
        if category.title == "분유" {
            BottleGlyphView(tint: category.tintColor)
        } else {
            Image(systemName: category.symbolName)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 16, height: 16)
        }
    }
}

private struct BottleGlyphView: View {
    let tint: Color

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(tint.opacity(0.18))
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(tint, lineWidth: 1.4)
                }
                .frame(width: 10, height: 15)
                .offset(y: 3)

            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                .fill(tint)
                .frame(width: 7, height: 4)
                .offset(y: 0)

            Capsule()
                .fill(tint)
                .frame(width: 6, height: 4)
                .offset(y: -3)
        }
        .frame(width: 16, height: 16)
    }
}
