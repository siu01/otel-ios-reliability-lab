import SwiftUI

@main
struct OTelReliabilityLabApp: App {
    @StateObject private var controller = ExperimentController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                .task {
                    controller.autorunIfRequested()
                    controller.resumeIfRequested()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        controller.handleBackgroundTransition()
                    }
                }
        }
    }
}
