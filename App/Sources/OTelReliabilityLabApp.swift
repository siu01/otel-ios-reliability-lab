import SwiftUI

@main
struct OTelReliabilityLabApp: App {
    @StateObject private var controller = ExperimentController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .task {
                    controller.autorunIfRequested()
                }
        }
    }
}
