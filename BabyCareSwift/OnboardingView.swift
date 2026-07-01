import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: BabyCareStore
    @State private var babyName = ""
    @State private var birthDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()

    var body: some View {
        ZStack {
            GlassBackground()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Baby Care")
                        .font(.largeTitle.weight(.bold))
                    Text("처음 시작하기 위해 아기 이름과 출생일을 입력하세요.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    TextField("아기 이름", text: $babyName)
                        .textInputAutocapitalization(.never)
                        .padding(14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    DatePicker("출생일", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                .padding(18)
                .glassCard()

                Button {
                    store.configureBaby(name: babyName, birthDate: birthDate)
                } label: {
                    Label("기록 시작", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(24)
        }
    }
}
