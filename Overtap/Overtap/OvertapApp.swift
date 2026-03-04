import SwiftUI

@main
struct OvertapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .defaultSize(width: 480, height: 680)
        #endif
    }
}
