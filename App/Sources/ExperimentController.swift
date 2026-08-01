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
    @Published private(set) var latestRunID: UUID?
    @Published private(set) var isRunning = false

    let experimentID = ExperimentID(rawValue: "E000")!
    private let telemetry = TelemetryRuntime()

    var deliveryText: String {
        guard generatedCount > 0 else { return "—" }
        let rate = Double(receivedCount) / Double(generatedCount)
        return rate.formatted(.percent.precision(.fractionLength(1)))
    }

    func runBaselineBurst() {
        guard !isRunning else { return }
        isRunning = true
        status = "Configuring exporter"

        Task { @MainActor in
            do {
                let run = RunDescriptor(
                    experimentID: experimentID,
                    plannedSpanCount: plannedSpanCount,
                    transport: transport,
                    persistence: persistence
                )
                latestRunID = run.runID
                let evidenceStore = try RunEvidenceStore(run: run)
                try telemetry.configure(for: run)

                status = "Ending \(plannedSpanCount) probe spans"
                var generated: [GeneratedSpanRecord] = []
                generated.reserveCapacity(plannedSpanCount)

                for sequence in 1...plannedSpanCount {
                    let endedAt = Int64(Date().timeIntervalSince1970 * 1_000_000_000)
                    telemetry.emitProbe(
                        sequence: sequence,
                        run: run,
                        endedAtUnixNanoseconds: endedAt
                    )
                    generated.append(
                        GeneratedSpanRecord(
                            experimentID: experimentID,
                            runID: run.runID,
                            sequence: sequence,
                            endedAtUnixNanoseconds: endedAt
                        )
                    )
                }

                try evidenceStore.writeGeneratedRecords(generated)
                generatedCount = generated.count
                receivedCount = 0
                status = "Flushing exporter"
                telemetry.forceFlush()
                status = "Burst complete — reconcile on host"
            } catch {
                status = "Failed: \(error.localizedDescription)"
            }
            isRunning = false
        }
    }

    func reset() {
        generatedCount = 0
        receivedCount = 0
        latestRunID = nil
        status = "Ready for baseline"
    }
}
