import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var store: BabyCareStore

    var body: some View {
        if store.isConfigured {
            TabView {
                RecordView()
                    .tabItem {
                        Label("기록", systemImage: "clock.badge.checkmark")
                    }

                PastRecordView()
                    .tabItem {
                        Label("지난기록", systemImage: "calendar")
                    }

                AnalysisView()
                    .tabItem {
                        Label("분석", systemImage: "chart.xyaxis.line")
                    }

                SettingsView()
                    .tabItem {
                        Label("설정", systemImage: "gearshape")
                    }
            }
        } else {
            OnboardingView()
        }
    }
}
