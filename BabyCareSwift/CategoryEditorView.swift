import SwiftUI

struct CategoryEditorView: View {
    @EnvironmentObject private var store: BabyCareStore
    @Environment(\.dismiss) private var dismiss
    @State private var newTitle = ""
    @State private var newUnit: BabyCareUnit = .count
    @FocusState private var newTitleFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                List {
                    Section("표시할 기록") {
                        ForEach(store.categories) { category in
                            HStack(spacing: 12) {
                                CareCategorySymbolView(category: category)
                                    .foregroundStyle(category.tintColor)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(category.title)
                                    Text(category.unit == .count ? "횟수 기록" : "\(category.unit.rawValue) 단위 기록")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Toggle("", isOn: Binding(
                                    get: { category.isEnabled },
                                    set: { store.setCategoryEnabled(category, enabled: $0) }
                                ))
                                .labelsHidden()

                                if !category.isDefault {
                                    Button(role: .destructive) {
                                        store.removeCategory(category)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }

                    Section("커스텀 추가") {
                        TextField("예: 약, 체온, 산책", text: $newTitle)
                            .focused($newTitleFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                newTitleFocused = false
                            }
                        Picker("단위", selection: $newUnit) {
                            ForEach(BabyCareUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }

                        Button {
                            store.addCustomCategory(title: newTitle, unit: newUnit)
                            newTitle = ""
                            newUnit = .count
                        } label: {
                            Label("추가", systemImage: "plus.circle.fill")
                        }
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("기록 버튼 편집")
            .simultaneousGesture(TapGesture().onEnded {
                newTitleFocused = false
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}
