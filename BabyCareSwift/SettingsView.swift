import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BabyCareStore
    @State private var activeBabyField: BabyProfileField?
    @State private var showingResetConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                Form {
                    Section("아기 정보") {
                        Button {
                            activeBabyField = .name
                        } label: {
                            LabeledContent("이름", value: store.profile?.name ?? "-")
                        }
                        .buttonStyle(.plain)

                        Button {
                            activeBabyField = .birthDate
                        } label: {
                            LabeledContent("출생일", value: store.profile.map { BabyCareFormatters.fullDate.string(from: $0.birthDate) } ?? "-")
                        }
                        .buttonStyle(.plain)

                        LabeledContent("현재", value: store.babyAgeText())
                    }

                    Section("기록") {
                        NavigationLink {
                            CategoryEditorView()
                        } label: {
                            Label("기록 버튼 편집", systemImage: "slider.horizontal.3")
                        }
                        LabeledContent("활성 버튼", value: "\(store.enabledCategories.count)개")
                    }

                    Section("유료 기능") {
                        PremiumSyncView()
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }

                    Section("데이터") {
                        Button(role: .destructive) {
                            showingResetConfirm = true
                        } label: {
                            Label("전체 데이터 초기화", systemImage: "trash")
                        }
                    }

                    Section("앱") {
                        LabeledContent("탭", value: "기록, 분석, 설정")
                        LabeledContent("저장", value: "로컬 기기")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("설정")
            .sheet(item: $activeBabyField) { field in
                BabyProfileEditorView(field: field)
            }
            .confirmationDialog("모든 기록을 삭제할까요?", isPresented: $showingResetConfirm, titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    store.resetAllData()
                }
                Button("취소", role: .cancel) { }
            }
        }
    }
}

private struct BabyProfileEditorView: View {
    @EnvironmentObject private var store: BabyCareStore
    @Environment(\.dismiss) private var dismiss
    let field: BabyProfileField
    @State private var babyName: String
    @State private var birthDate: Date
    @FocusState private var babyNameFocused: Bool

    init(field: BabyProfileField) {
        self.field = field
        let profile = defaultBabyProfile()
        _babyName = State(initialValue: profile.name)
        _birthDate = State(initialValue: profile.birthDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("아기 정보") {
                    if field == .name {
                        TextField("아기 이름", text: $babyName)
                            .focused($babyNameFocused)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .onSubmit {
                                babyNameFocused = false
                            }
                    } else {
                        DatePicker("출생일", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                }
            }
            .navigationTitle(field.title)
            .simultaneousGesture(TapGesture().onEnded {
                babyNameFocused = false
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        switch field {
                        case .name:
                            store.configureBaby(name: babyName, birthDate: store.profile?.birthDate ?? birthDate)
                        case .birthDate:
                            store.configureBaby(name: store.profile?.name ?? "아기", birthDate: birthDate)
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let profile = store.profile {
                babyName = profile.name
                birthDate = profile.birthDate
            }
        }
    }
}

private enum BabyProfileField: String, Identifiable {
    case name
    case birthDate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name:
            return "이름 수정"
        case .birthDate:
            return "출생일 수정"
        }
    }
}

private func defaultBabyProfile() -> BabyProfile {
    BabyProfile(
        name: "",
        birthDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    )
}
