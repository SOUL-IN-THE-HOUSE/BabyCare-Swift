import SwiftUI
import WidgetKit

struct BabyCareWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: BabyCareWidgetSnapshot
}

struct BabyCareWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BabyCareWidgetEntry {
        BabyCareWidgetEntry(
            date: Date(),
            snapshot: BabyCareWidgetSnapshot(
                profileName: "아기",
                ddayText: "D+1",
                totalFeedCount: 2,
                feedStats: [
                    WidgetFeedStat(id: UUID(), title: "분유", tintHex: "D37B4A", count: 2, totalAmount: 160, unit: .milliliter, lastDate: Date()),
                    WidgetFeedStat(id: UUID(), title: "모유", tintHex: "F08BA8", count: 1, totalAmount: 80, unit: .milliliter, lastDate: Date())
                ],
                lastFeedTitle: "분유",
                lastFeedDate: Date().addingTimeInterval(-5400),
                updatedAt: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BabyCareWidgetEntry) -> Void) {
        completion(BabyCareWidgetEntry(date: Date(), snapshot: BabyCareWidgetSnapshot.make()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BabyCareWidgetEntry>) -> Void) {
        let now = Date()
        let entry = BabyCareWidgetEntry(date: now, snapshot: BabyCareWidgetSnapshot.make(now: now))
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct BabyCareWidgetEntryView: View {
    var entry: BabyCareWidgetProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            inlineView
        case .accessoryCircular:
            circularView
        default:
            rectangularView
        }
    }

    private var inlineView: some View {
        Text(entry.snapshot.inlineText)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private var circularView: some View {
        VStack(spacing: 1) {
            Text(entry.snapshot.circularText)
                .font(.headline.weight(.bold))
            Text("회")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private var rectangularView: some View {
        let snapshot = entry.snapshot

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(snapshot.profileName) · \(snapshot.ddayText)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(snapshot.summaryLine)
                        .font(.headline.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer()

                if let lastFeedDate = snapshot.lastFeedDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("마지막")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(BabyCareFormatters.relativeTime(from: lastFeedDate, to: snapshot.updatedAt))
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
            }

            Text(snapshot.statsLine)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            if let lastFeedTitle = snapshot.lastFeedTitle, let lastFeedDate = snapshot.lastFeedDate {
                Text("\(lastFeedTitle) · \(BabyCareFormatters.relativeTime(from: lastFeedDate, to: snapshot.updatedAt))")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}

@main
struct BabyCareWidgetBundle: WidgetBundle {
    var body: some Widget {
        BabyCareWidget()
    }
}

struct BabyCareWidget: Widget {
    let kind: String = "BabyCareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BabyCareWidgetProvider()) { entry in
            BabyCareWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("육아 기록")
        .description("오늘의 수유 횟수, 용량, 마지막 기록 시간을 잠금화면에서 확인합니다.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}
