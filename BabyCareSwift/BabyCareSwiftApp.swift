import SwiftUI

@main
struct BabyCareSwiftApp: App {
    @StateObject private var store = BabyCareStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
