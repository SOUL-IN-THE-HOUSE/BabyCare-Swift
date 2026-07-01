import SwiftUI

struct RecordView: View {
    @EnvironmentObject private var store: BabyCareStore
    @State private var showingEditor = false
    @State private var selectedDate = Date()
    @State private var selectedEntry: CareEntry?
    @State private var draftAmount = 0
    @State private var draftNote = ""
    @State private var draftDate = Date()
    @State private var activeCategory: CareCategory?

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        profileHeader
                        categoryScroller
                        timeline
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditor) {
                CategoryEditorView()
            }
            .sheet(item: $selectedEntry) { entry in
                EntryEditSheet(
                    entry: entry,
                    amount: $draftAmount,
                    note: $draftNote,
                    date: $draftDate
                ) {
                    store.updateEntry(
                        entry,
                        amount: entry.unit.needsAmount ? draftAmount : nil,
                        note: draftNote,
                        date: draftDate
                    )
                    selectedEntry = nil
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .onChange(of: selectedEntry?.id) { _, newValue in
                if newValue == nil {
                    activeCategory = nil
                }
            }
            .onAppear {
                selectedDate = Date()
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Button {
                    shiftDay(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)

                Text(BabyCareFormatters.fullDate.string(from: selectedDate))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    selectedDate = Date()
                } label: {
                    Text("오늘")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)

                if !isTodaySelected {
                    Button {
                        shiftDay(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 2) {
                Text(store.profile?.name ?? "아기")
                    .font(.title2.weight(.bold))
                Text(store.babyDdayText(on: selectedDate))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
        .padding(.bottom, 4)
    }

    private var categoryScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(store.enabledCategories) { category in
                    Button {
                        record(category)
                    } label: {
                        VStack(spacing: 3) {
                            CareCategorySymbolView(category: category)
                                .frame(height: 18)
                            Text(category.title)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(summaryText(for: category))
                                .font(.caption2)
                                .lineLimit(2)
                                .minimumScaleFactor(0.72)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(category.tintColor)
                        .frame(width: 74, height: 74)
                        .padding(4)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(category.tintColor.opacity(0.25), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        activeCategory = category
                    })
                }
                Button {
                    showingEditor = true
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption.weight(.semibold))
                        Text("편집")
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                        Text("추가/삭제")
                            .font(.caption2)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.secondary)
                    .frame(width: 74, height: 74)
                    .padding(4)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.secondary.opacity(0.18), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("타임라인")
                    .font(.headline)
                Spacer()
                Text(BabyCareFormatters.fullDate.string(from: selectedDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let activeCategory {
                HStack(spacing: 8) {
                    CareCategorySymbolView(category: activeCategory)
                    Text(activeCategory.title)
                    Text(activeCategory.unit.rawValue)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(activeCategory.tintColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }

            if timelineEntries.isEmpty {
                ContentUnavailableView("해당 날짜 기록이 없습니다", systemImage: "clock", description: Text("상단 버튼을 눌러 기록을 남기세요."))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 10) {
                    ForEach(timelineEntries) { entry in
                        TimelineRowView(entry: entry)
                            .onTapGesture {
                                draftAmount = entry.amount ?? entry.unit.defaultAmount
                                draftNote = entry.note
                                draftDate = entry.date
                                selectedEntry = entry
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.deleteEntry(entry)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private func record(_ category: CareCategory) {
        let amount = category.unit.needsAmount ? category.unit.defaultAmount : nil
        store.addEntry(category: category, amount: amount, note: "", date: entryDate(on: selectedDate))
    }

    private func summaryText(for category: CareCategory) -> String {
        let matched = store.entries(on: selectedDate).filter { $0.categoryId == category.id }
        guard let last = matched.map(\.date).max() else {
            if category.unit.needsAmount {
                return "0회"
            }
            return "0회"
        }

        if category.unit.needsAmount {
            let total = matched.compactMap(\.amount).reduce(0, +)
            return "\(matched.count)회 · \(total)\(category.unit.rawValue)\n\(BabyCareFormatters.relativeTime(from: last))"
        }
        return "\(matched.count)회\n\(BabyCareFormatters.relativeTime(from: last))"
    }

    private var timelineEntries: [CareEntry] {
        Array(store.entries(on: selectedDate).sorted { $0.date > $1.date }.prefix(30))
    }

    private func shiftDay(by value: Int) {
        guard let nextDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) else { return }
        let todayStart = Calendar.current.startOfDay(for: Date())
        guard Calendar.current.startOfDay(for: nextDate) <= todayStart else { return }
        selectedDate = nextDate
    }

    private var isTodaySelected: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private func entryDate(on date: Date) -> Date {
        let calendar = Calendar.current
        let now = Date()
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        var combined = DateComponents()
        combined.year = selectedComponents.year
        combined.month = selectedComponents.month
        combined.day = selectedComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        return calendar.date(from: combined) ?? date
    }
}

private struct EntryEditSheet: View {
    let entry: CareEntry
    @Binding var amount: Int
    @Binding var note: String
    @Binding var date: Date
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
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
                            .font(.title3.weight(.bold))

                            Text(entry.categoryTitle)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(entry.tintColor)
                        }

                        HStack(spacing: 8) {
                            TagChip(text: "기록", value: entry.categoryTitle, tint: entry.tintColor)
                            TagChip(text: "먹은 시간", value: BabyCareFormatters.time.string(from: date), tint: entry.tintColor)
                            if entry.unit.needsAmount {
                                TagChip(text: "먹은 양", value: "\(amount)\(entry.unit.rawValue)", tint: entry.tintColor)
                            } else {
                                TagChip(text: "구분", value: entry.unit.rawValue, tint: entry.tintColor)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("먹은 시간")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        DatePicker("먹은 시간", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                    }

                    if entry.unit.needsAmount {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("먹은 양")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            AmountDial(amount: $amount, unit: entry.unit)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("메모", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .background(GlassBackground())
            .safeAreaInset(edge: .bottom) {
                Button {
                    onSave()
                    dismiss()
                } label: {
                    Label("수정 저장", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("기록 수정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct TagChip: View {
    let text: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .foregroundStyle(.secondary)
            Text(value)
                .foregroundStyle(tint)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

private struct AmountDial: View {
    @Binding var amount: Int
    let unit: BabyCareUnit
    @State private var dragStartAmount: Int?

    var body: some View {
        VStack(spacing: 10) {
            Text("\(amount)")
                .font(.system(size: 68, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text(unit.rawValue)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("좌우로 스와이프해서 조절")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .glassCard()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let base = dragStartAmount ?? amount
                    if dragStartAmount == nil {
                        dragStartAmount = base
                    }
                    let offset = Int(value.translation.width / 6)
                    let next = max(unit.step, base + (offset * unit.step))
                    if next != amount {
                        amount = next
                    }
                }
                .onEnded { value in
                    let base = dragStartAmount ?? amount
                    let offset = Int(value.translation.width / 6)
                    amount = max(unit.step, base + (offset * unit.step))
                    dragStartAmount = nil
                }
        )
        .overlay(alignment: .leading) {
            Button {
                amount = max(unit.step, amount - unit.step)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }
            .padding(.leading, 20)
        }
        .overlay(alignment: .trailing) {
            Button {
                amount += unit.step
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            .padding(.trailing, 20)
        }
    }
}
