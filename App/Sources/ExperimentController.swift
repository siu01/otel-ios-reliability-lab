import Foundation
import ReliabilityCore

@MainActor
final class ExperimentController: ObservableObject {
    @Published var transport: Transport = .http
    @Published var persistence: PersistenceMode = .disabled
    @Published var plannedSpanCount = 100
    @Published private(set) var generatedCount = 0
    @Published private(set) var receivedCount = 0
    @Published private(set) var status = "Ready for dry run"

    let experimentID = ExperimentID(rawValue: "E000")!

    var deliveryText: String {
        guard generatedCount > 0 else { return "—" }
        let rate = Double(receivedCount) / Double(generatedCount)
        return rate.formatted(.percent.precision(.fractionLength(1)))
    }

    func runDryBurst() {
        generatedCount = plannedSpanCount
        receivedCount = 0
        status = "Dry run recorded — exporter not wired yet"
    }

    func reset() {
        generatedCount = 0
        receivedCount = 0
        status = "Ready for dry run"
    }
}

