import SwiftUI

struct PremiumSyncView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("클라우드 동기화", systemImage: "lock.icloud.fill")
                .font(.title3.weight(.bold))

            Text("Google Drive와 iCloud에 기록, 분석 데이터, 설정을 업로드하거나 다운로드하는 기능은 유료 기능으로 분리되어 있습니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Label("기기 변경 후 이어서 사용", systemImage: "iphone.gen3")
                Label("기록과 분석 데이터 백업", systemImage: "chart.line.uptrend.xyaxis")
                Label("가족 공유용 데이터 이전 기반", systemImage: "person.2.fill")
            }
            .font(.subheadline)

            Button {
            } label: {
                Label("유료 기능 준비 중", systemImage: "cart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(true)
        }
        .padding(16)
        .glassCard()
    }
}
