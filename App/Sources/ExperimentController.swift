import Foundation
import ReliabilityCore

@MainActor
final class ExperimentController: ObservableObject {
    @Published var transport: Transport = .http
    @Published var persistence: PersistenceMode = .disabled
    @Published var flushMode: FlushMode = .explicit
    @Published var httpClientMode: HTTPClientMode = .officialBase
    @Published var plannedSpanCount = 100
    @Published private(set) var generatedCount = 0
    @Published private(set) var receivedCount = 0
    @Published private(set) var status = "Ready for dry run"
    @Published private(set) var latestRunID: UUID?
    @Published private(set) var isRunning = false
    @Published private(set) var isReconciled = false

    let experimentID: ExperimentID
    private let telemetry = TelemetryRuntime()
    private let launchConfiguration: AutomationLaunchConfiguration
    private var didAutorun = false

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        let launchConfiguration = AutomationLaunchConfiguration(arguments: arguments)
        self.launchConfiguration = launchConfiguration
        experimentID = launchConfiguration.experimentID ?? ExperimentID(rawValue: "E000")!

        if let spanCount = launchConfiguration.spanCount {
            plannedSpanCount = spanCount
        }
        if let transport = launchConfiguration.transport {
            self.transport = transport
        }
        if let persistence = launchConfiguration.persistence {
            self.persistence = persistence
        }
        if let flushMode = launchConfiguration.flushMode {
            self.flushMode = flushMode
        }
        if let httpClientMode = launchConfiguration.httpClientMode {
            self.httpClientMode = httpClientMode
        }
        status = launchConfiguration.shouldAutorun
            ? "Automated baseline queued"
            : "Ready for baseline"
    }

    var deliveryText: String {
        guard generatedCount > 0 else { return "—" }
        guard isReconciled else { return "Pending" }
        let rate = Double(receivedCount) / Double(generatedCount)
        return rate.formatted(.percent.precision(.fractionLength(1)))
    }

    func autorunIfRequested() {
        guard launchConfiguration.shouldAutorun, !didAutorun else { return }
        didAutorun = true
        runBaselineBurst(runID: launchConfiguration.runID)
    }

    func runBaselineBurst(runID: UUID? = nil) {
        guard !isRunning else { return }
        isRunning = true
        status = "Configuring exporter"

        Task { @MainActor in
            do {
                let run = RunDescriptor(
                    experimentID: experimentID,
                    runID: runID ?? UUID(),
                    plannedSpanCount: plannedSpanCount,
                    transport: transport,
                    persistence: persistence,
                    flushMode: flushMode,
                    httpClientMode: httpClientMode
                )
                latestRunID = run.runID
                isReconciled = false
                let evidenceStore = try RunEvidenceStore(run: run)
                try telemetry.configure(
                    for: run,
                    runEvidenceDirectory: evidenceStore.runDirectory
                )

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
                if flushMode == .explicit {
                    status = "Flushing exporter"
                    telemetry.forceFlush()
                } else {
                    status = "Leaving export to scheduled workers"
                }
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
        isReconciled = false
        status = "Ready for baseline"
    }
}
