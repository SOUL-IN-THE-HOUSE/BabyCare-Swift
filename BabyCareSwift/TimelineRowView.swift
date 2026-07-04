import SwiftUI

struct TimelineRowView: View {
    let entry: CareEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text(timePeriodText)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 32, alignment: .trailing)
                    Text(timeValueText)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 50, alignment: .leading)
                }
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(width: 82, alignment: .trailing)

                Text(BabyCareFormatters.relativeTime(from: entry.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 94, alignment: .trailing)

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(entry.tintColor.opacity(0.12))
                    CareCategorySymbolView(category: CareCategory(
                        id: entry.categoryId,
                        title: entry.categoryTitle,
                        symbolName: entry.symbolName,
                        tintHex: entry.tintHex,
                        unit: entry.unit,
                        isEnabled: true,
                        isDefault: true
                    ))
                    .foregroundStyle(entry.tintColor)
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(entry.categoryTitle)
                            .font(.subheadline.weight(.semibold))
                        if entry.unit.needsAmount {
                            Text(entry.amountText)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(entry.tintColor)
                        }
                    }
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                    if !entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(entry.note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .flatGlassCard(cornerRadius: 14)
    }

    private var timePeriodText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.dateFormat = "a"
        return formatter.string(from: entry.date)
    }

    private var timeValueText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "h:mm"
        return formatter.string(from: entry.date)
    }
}
