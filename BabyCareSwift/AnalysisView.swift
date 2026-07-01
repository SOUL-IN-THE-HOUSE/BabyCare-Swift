import Charts
import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject private var store: BabyCareStore
    @State private var selectedCategoryId: UUID?
    @State private var selectedRange: AnalysisRange = .day

    private var selectedCategory: CareCategory? {
        if let selectedCategoryId,
           let category = store.enabledCategories.first(where: { $0.id == selectedCategoryId }) {
            return category
        }
        return store.enabledCategories.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        categoryPicker
                        rangePicker
                        chartCard
                        averagesCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("분석")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedCategoryId = selectedCategory?.id
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.enabledCategories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        HStack(spacing: 8) {
                            CareCategorySymbolView(category: category)
                                .frame(width: 18, height: 18)
                            Text(category.title)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(selectedCategory?.id == category.id ? category.tintColor.opacity(0.2) : Color.clear)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .foregroundStyle(category.tintColor)
                }
            }
        }
    }

    private var rangePicker: some View {
        Picker("기간", selection: $selectedRange) {
            ForEach(AnalysisRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(selectedCategory?.title ?? "기록")
                    .font(.headline)
                Spacer()
                Text(selectedCategory.map { BabyCareAnalytics.averageText(points: points(for: $0), unit: $0.unit) } ?? "")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let category = selectedCategory {
                chartScrollView(for: category)
            }
        }
        .padding(16)
        .glassCard()
    }

    @ViewBuilder
    private func chartScrollView(for category: CareCategory) -> some View {
        let categoryPoints = points(for: category)
        let chartWidth = chartWidth(for: categoryPoints.count)

        if selectedRange == .day {
            ScrollView(.horizontal, showsIndicators: false) {
                chart(for: category, points: categoryPoints)
                    .frame(width: chartWidth, height: 220)
            }
        } else {
            chart(for: category, points: categoryPoints)
                .frame(height: 220)
        }
    }

    private func chart(for category: CareCategory, points: [AnalysisPoint]) -> some View {
        Chart(points) { point in
            AreaMark(
                x: .value("구간", point.label),
                y: .value("값", category.unit == .count ? point.count : point.totalAmount)
            )
            .foregroundStyle(category.tintColor.opacity(0.14))

            LineMark(
                x: .value("구간", point.label),
                y: .value("값", category.unit == .count ? point.count : point.totalAmount)
            )
            .foregroundStyle(category.tintColor)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            PointMark(
                x: .value("구간", point.label),
                y: .value("값", category.unit == .count ? point.count : point.totalAmount)
            )
            .symbolSize(38)
            .foregroundStyle(category.tintColor)
        }
        .chartXAxis {
            AxisMarks(values: axisLabels(for: category)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text(value.as(String.self) ?? "")
                        .font(.caption2)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }

    private var averagesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("전체 평균", systemImage: "chart.bar.doc.horizontal")
                .font(.headline)

            ForEach(store.enabledCategories) { category in
                let categoryPoints = points(for: category)
                HStack {
                    CareCategorySymbolView(category: category)
                        .foregroundStyle(category.tintColor)
                        .frame(width: 28)
                    Text(category.title)
                    Spacer()
                    Text(BabyCareAnalytics.averageText(points: categoryPoints, unit: category.unit))
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func points(for category: CareCategory) -> [AnalysisPoint] {
        BabyCareAnalytics.points(entries: store.entries, category: category, range: selectedRange)
    }

    private func axisLabels(for category: CareCategory) -> [String] {
        let categoryPoints = points(for: category)
        switch selectedRange {
        case .day:
            return categoryPoints.map(\.label)
        case .week:
            return categoryPoints.map(\.label)
        case .month:
            return categoryPoints.map(\.label)
        }
    }

    private func chartWidth(for pointCount: Int) -> CGFloat {
        let minimumVisiblePoints = 10
        let pointsToShow = max(pointCount, minimumVisiblePoints)
        return CGFloat(pointsToShow) * 52
    }
}
