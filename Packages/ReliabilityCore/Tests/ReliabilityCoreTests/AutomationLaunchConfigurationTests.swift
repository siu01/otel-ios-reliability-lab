import Foundation
import Testing
@testable import ReliabilityCore

@Suite("Automation launch configuration")
struct AutomationLaunchConfigurationTests {
    @Test("parses a fully pinned automated run")
    func parsesPinnedRun() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-autorun",
            "--lab-run-id=00000000-0000-0000-0000-000000000042",
            "--lab-span-count=250",
            "--lab-transport=http",
            "--lab-persistence=officialInstant",
        ])

        #expect(config.shouldAutorun)
        #expect(config.runID == UUID(uuidString: "00000000-0000-0000-0000-000000000042"))
        #expect(config.spanCount == 250)
        #expect(config.transport == .http)
        #expect(config.persistence == .officialInstant)
    }

    @Test("invalid values do not silently become valid defaults")
    func rejectsInvalidValues() {
        let config = AutomationLaunchConfiguration(arguments: [
            "OTelReliabilityLab",
            "--lab-span-count=0",
            "--lab-transport=udp",
            "--lab-persistence=yes",
        ])

        #expect(!config.shouldAutorun)
        #expect(config.spanCount == nil)
        #expect(config.transport == nil)
        #expect(config.persistence == nil)
    }
}

