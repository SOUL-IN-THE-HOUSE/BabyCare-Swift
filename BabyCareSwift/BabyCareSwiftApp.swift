import SwiftUI

@main
struct BabyCareSwiftApp: App {
    @StateObject private var store = BabyCareStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                KeyboardDismissTapInstaller()
                    .frame(width: 0, height: 0)
            }
            .environmentObject(store)
        }
    }
}
